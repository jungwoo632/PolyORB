------------------------------------------------------------------------------
--                                                                          --
--                            GLADE COMPONENTS                              --
--                                                                          --
--                S Y S T E M . G A R L I C . S T R E A M S                 --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $Revision$                             --
--                                                                          --
--         Copyright (C) 1996-1998 Free Software Foundation, Inc.           --
--                                                                          --
-- GARLIC is free software;  you can redistribute it and/or modify it under --
-- terms of the  GNU General Public License  as published by the Free Soft- --
-- ware Foundation;  either version 2,  or (at your option)  any later ver- --
-- sion.  GARLIC is distributed  in the hope that  it will be  useful,  but --
-- WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHANTABI- --
-- LITY or  FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public  --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License  distributed with GARLIC;  see file COPYING.  If  --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--               GLADE  is maintained by ACT Europe.                        --
--               (email: glade-report@act-europe.fr)                        --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Streams;         use Ada.Streams;
with System.Garlic.Debug; use System.Garlic.Debug;

package body System.Garlic.Streams is

   subtype Output_Line is String (1 .. 48);

   Hex : constant String      := "0123456789ABCDEF";
   Nil : constant Output_Line := (others => ' ');

   Node_Size : constant Stream_Element_Count := 4096;

   procedure Free is
      new Ada.Unchecked_Deallocation (Node, Node_Ptr);

   ----------
   -- Copy --
   ----------

   procedure Copy
     (Source : in out Params_Stream_Type;
      Target : access Params_Stream_Type) is
   begin
      if Target.First /= null then
         Free (Target.First);
      end if;
      Target.First         := Source.First;
      Target.Current       := Source.Current;
      Target.Special_First := Source.Special_First;
      Target.Count         := Source.Count;
      Source.First         := null;
   end Copy;

   ----------------
   -- Deallocate --
   ----------------

   procedure Deallocate (Stream : in out Params_Stream_Access) is
      Next : Node_Ptr;
   begin
      if Stream = null then
         return;
      end if;
      while Stream.First /= null loop
         Next := Stream.First.Next;
         Free (Stream.First);
         Stream.First := Next;
      end loop;
      Free (Stream);
   end Deallocate;

   ----------
   -- Dump --
   ----------

   procedure Dump
     (Level  : in System.Garlic.Debug.Debug_Level;
      Stream : in Ada.Streams.Stream_Element_Array;
      Key    : in System.Garlic.Debug.Debug_Key) is
      Index   : Natural := 1;
      Output  : Output_Line;
   begin
      if Debug_Mode (Level, Key) then
         for I in Stream'Range loop
            Output (Index)     := ' ';
            Output (Index + 1) := Hex (Natural (Stream (I) / 16) + 1);
            Output (Index + 2) := Hex (Natural (Stream (I) mod 16) + 1);
            Index := Index + 3;

            if Index > Output'Length then
               Print_Debug_Info (Level, Output, Key);
               Index := 1;
               Output := Nil;
            end if;
         end loop;

         if Index /= 1 then
            Print_Debug_Info (Level, Output (1 .. Index - 1), Key);
         end if;
      end if;
   end Dump;

   ----------
   -- Read --
   ----------

   procedure Read
     (Stream : in out Params_Stream_Type;
      Item   : out Stream_Element_Array;
      Last   : out Stream_Element_Offset) is
      First  : Node_Ptr renames Stream.First;
      Other  : Node_Ptr;
      Offset : Stream_Element_Offset := Item'First;
      Count  : Stream_Element_Count := Item'Length;
      Length : Stream_Element_Count;
   begin
      while First /= null and then Count > 0 loop
         Length :=
           Stream_Element_Count'Min (First.Last - First.Current, Count);
         Item (Offset .. Offset + Length - 1) :=
           First.Content (First.Current .. First.Current + Length - 1);
         Count := Count - Length;
         Offset := Offset + Length;
         First.Current := First.Current + Length;
         if First.Current >= First.Last then
            Other := First;
            First := First.Next;
            Free (Other);
         end if;
      end loop;
      Last := Offset - 1;
      Stream.Count := Stream.Count - (Offset - Item'First);
      if First = null then

         --  Set Current to null to allow further Write to be done

         Stream.Current := null;

      end if;
   end Read;

   ---------------------------
   -- To_Params_Stream_Type --
   ---------------------------

   procedure To_Params_Stream_Type
     (Content : Stream_Element_Array;
      Params  : access Params_Stream_Type) is
   begin
      Write (Params.all, Content);
   end To_Params_Stream_Type;

   ------------------------------
   -- To_Stream_Element_Access --
   ------------------------------

   function To_Stream_Element_Access
     (Params : access Params_Stream_Type;
      Unused : Ada.Streams.Stream_Element_Count := 0)
     return Stream_Element_Access is
      First   : Node_Ptr := new Node (Node_Size);
      Current : Node_Ptr := First;
      Total   : Stream_Element_Count := 0;
   begin
      loop
         Current.Last := 0;
         Read (Params.all, Current.Content, Current.Last);
         Total := Total + Current.Last;
         exit when Current.Last < Node_Size;
         Current.Next := new Node (Node_Size);
         Current := Current.Next;
      end loop;
      declare
         Result : constant Stream_Element_Access :=
           new Stream_Element_Array (1 .. Total + Unused);
         Index  : Stream_Element_Offset := 1 + Unused;
      begin
         Current := First;
         while Current /= null loop
            Result (Index .. Index + Current.Last - 1) :=
              Current.Content (1 .. Current.Last);
            Index := Index + Current.Last;
            First := Current.Next;
            Free (Current);
            Current := First;
         end loop;
         return Result;
      end;
   end To_Stream_Element_Access;

   -----------------------------
   -- To_Stream_Element_Array --
   -----------------------------

   function To_Stream_Element_Array
     (Params : access Params_Stream_Type;
      Unused : Ada.Streams.Stream_Element_Count := 0)
      return Stream_Element_Array is
      Data   : Stream_Element_Access := To_Stream_Element_Access (Params);
      Result : constant Stream_Element_Array := Data.all;
   begin
      Free (Data);
      return Result;
   end To_Stream_Element_Array;

   -----------
   -- Write --
   -----------

   procedure Write
     (Stream : in out Params_Stream_Type;
      Item   : in Stream_Element_Array) is
      Length  : constant Stream_Element_Count := Item'Length;
      Current : Node_Ptr renames Stream.Current;
   begin
      if Current = null then
         if Stream.First = null then

            --  This is the first call (maybe after a full read)

            Stream.First :=
              new Node (Stream_Element_Count'Max
                        (Stream.Initial_Size,
                         Stream_Element_Count'Max (Node_Size, Length)));
         end if;
         Current := Stream.First;
      end if;

      Stream.Count := Stream.Count + Item'Length;

      if Stream.Special_First then

         --  We make a special handling to add a header in front of
         --  the packet. Current points to the head, and new packets
         --  (if needed) will be added in order in front of regular
         --  packets.

         declare
            Special : Node_Ptr :=
             new Node (Stream_Element_Count'Max (Node_Size, Length));
         begin
            Special.Next := Stream.First;
            Stream.First := Special;
            Current := Stream.First;
            Current.Content (1 .. Length) := Item;
            Current.Last := Length + 1;
            Stream.Special_First := False;
            Stream.Count := Stream.Count + Length;
            return;
         end;
      end if;
      if Length + Current.Last - 1 > Current.Size then
         declare
            Old_Next : constant Node_Ptr := Current.Next;
         begin

            --  We chain to the 'Current' packet, while preserving the
            --  original Next field. This is used in the case where we
            --  insert the header at the beginning of the Stream.

            Current.Next :=
             new Node (Stream_Element_Count'Max (Node_Size, Length));
            Current := Current.Next;
            Current.Next := Old_Next;
         end;
      end if;
      Current.Content (Current.Last .. Current.Last + Length - 1) :=
        Item;
      Current.Last := Current.Last + Length;
   end Write;

end System.Garlic.Streams;
