------------------------------------------------------------------------------
--                                                                          --
--                            GLADE COMPONENTS                              --
--                                                                          --
--                 S Y S T E M . G A R L I C . R E P L A Y                  --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                            $Revision$
--                                                                          --
--         Copyright (C) 1996-1999 Free Software Foundation, Inc.           --
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

with Ada.Real_Time;                   use Ada.Real_Time;
with Ada.Streams.Stream_IO;           use Ada.Streams.Stream_IO;
with System.Garlic.Debug;             use System.Garlic.Debug;
with System.Garlic.Heart;             use System.Garlic.Heart;
with System.Garlic.Options;           use System.Garlic.Options;
with System.Garlic.Physical_Location; use System.Garlic.Physical_Location;
with System.Garlic.Protocols;         use System.Garlic.Protocols;
with System.Garlic.Streams;           use System.Garlic.Streams;
with System.Garlic.Trace;             use System.Garlic.Trace;
with System.Garlic.Types;             use System.Garlic.Types;
with System.Garlic.Utils;             use System.Garlic.Utils;

package body System.Garlic.Replay is

   Private_Debug_Key : constant Debug_Key :=
     Debug_Initialize ("S_GARREP", "(s-garrep): ");

   procedure D
     (Message : in String;
      Key     : in Debug_Key := Private_Debug_Key)
     renames Print_Debug_Info;

   Trace_File : File_Type;
   --  Where to read the traces

   task type Engine_Type;
   type Engine_Type_Access is access Engine_Type;
   Engine : Engine_Type_Access;
   --  Reads and delivers the messages from the trace file

   ------------
   -- Create --
   ------------

   function Create return Protocols.Protocol_Access is
      Self : Protocol_Access := new Replay_Protocol;

   begin
      Register_Protocol (Self);
      return Self;
   end Create;

   -----------------
   -- Engine_Type --
   -----------------

   task body Engine_Type is
      PID   : Partition_ID;
      Code  : Any_Opcode;
      Data  : Stream_Element_Access;
      Error : Error_Type;
   begin
      pragma Debug (D ("Replay engine started"));

      while not End_Of_File (Trace_File) loop

         --  Read a new trace from file (new incoming message)

         declare
            Trace : Trace_Type :=
              Trace_Type'Input (Stream (Trace_File));

         begin
            pragma Debug
              (D ("Read trace from partition" & Trace.PID'Img &
                  " of length" & Trace.Data'Length'Img));

            --  The message should arrive at about the same time as
            --  during the recorded execution.

            declare
               Latency : Duration := To_Duration (Trace.Time);
            begin
               pragma Debug (D ("Replay network latency" & Latency'Img));
               delay Latency;
            end;

            --  Deliver message

            Analyze_Stream (PID, Code, Data, Trace.Data, 0, Error);
            Free (Trace.Data);
            exit when Found (Error);

            Process_Stream (PID, Code, Data, Error);
            Free (Data);

            exit when Found (Error);

            pragma Debug (D ("Message delivered"));
         end;
      end loop;

      --  When the partition is the boot partition, the trace file
      --  receives no QUIT request and exits the loop above when no
      --  incoming message is available. Thus, the replay has to
      --  initiate the shutdown itself.

      if Is_Boot_Server then
         Soft_Shutdown;
      end if;
   end Engine_Type;

   --------------
   -- Get_Name --
   --------------

   function Get_Name (P : access Replay_Protocol) return String is
   begin
      return "replay";
   end Get_Name;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Protocol  : access Replay_Protocol;
      Self_Data : in Utils.String_Access := null;
      Boot_Data : in Utils.String_Access := null;
      Boot_Mode : in Boolean := False;
      Error     : in out Error_Type)
   is
   begin
      --  Replay protocol is always loaded because its activation
      --  is determined at run-time. It should be activated here when
      --  we are sure that the boot server is replay.

      if Options.Execution_Mode = Replay_Mode
        and then Engine = null
      then

         --  Boot data provides a way to give an alternate trace file name

         if Boot_Data /= null and then Boot_Data'Length /= 0 then
            Set_Trace_File_Name (Boot_Data.all);
         end if;

         begin
            Open (Trace_File, In_File, Trace_File_Name.all);
         exception when others =>
            Throw (Error, "Cannot open " & Trace_File_Name.all);
         end;

         if not Found (Error) then
            --  We create an unnamed task on which we keep no reference

            Engine := new Engine_Type;
         end if;

      end if;

   end Initialize;

   ----------
   -- Send --
   ----------

   procedure Send
     (Protocol  : access Replay_Protocol;
      Partition : in Partition_ID;
      Data      : access Ada.Streams.Stream_Element_Array;
      Error     : in out Error_Type) is
   begin
      pragma Debug
         (D ("Send (but do nothing)" & Data'Length'Img & " bytes"));

      --  Send is a no-op since every partition gets its messages from
      --  the trace file.

      null;
   end Send;

   --------------
   -- Shutdown --
   --------------

   procedure Shutdown (Protocol : access Replay_Protocol) is
   begin
      if Execution_Mode = Replay_Mode then
         pragma Debug (D ("Closing trace file"));
         Close (Trace_File);
      end if;
   end Shutdown;

end System.Garlic.Replay;

