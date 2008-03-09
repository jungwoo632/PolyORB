------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--   P O L Y O R B . R E P R E S E N T A T I O N S . C D R . C O M M O N    --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2002-2008, Free Software Foundation, Inc.          --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 51 Franklin Street, Fifth    --
-- Floor, Boston, MA 02111-1301, USA.                                       --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;

with PolyORB.Fixed_Point;
with PolyORB.Log;
with PolyORB.References.IOR;
with PolyORB.Utils.Buffers;

package body PolyORB.Representations.CDR.Common is

   use PolyORB.Any;
   use PolyORB.Log;
   use PolyORB.Types;
   use PolyORB.Utils.Buffers;

   package L is
      new PolyORB.Log.Facility_Log ("polyorb.representations.cdr.common");
   procedure O (Message : String; Level : Log_Level := Debug)
      renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;

   --------------------------------
   -- Types conversion functions --
   --------------------------------

   function To_Long_Long is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Unsigned_Long_Long, PolyORB.Types.Long_Long);

   function To_Unsigned_Long_Long is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Long_Long, PolyORB.Types.Unsigned_Long_Long);

   function To_Long is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Unsigned_Long, PolyORB.Types.Long);

   function To_Unsigned_Long is
      new Ada.Unchecked_Conversion
     (PolyORB.Types.Long, PolyORB.Types.Unsigned_Long);

   function To_Short is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Unsigned_Short, PolyORB.Types.Short);

   function To_Unsigned_Short is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Short, PolyORB.Types.Unsigned_Short);

   subtype Double_Buf is Stream_Element_Array (1 .. 8);
   --  FIXME LONG DOUBLE
   subtype Long_Double_Buf is Stream_Element_Array (1 .. 12);
   pragma Warnings (Off);
   pragma Unreferenced (Long_Double_Buf);
   pragma Warnings (On);

   function To_Unsigned_Long is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Float, PolyORB.Types.Unsigned_Long);

   function To_Float is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Unsigned_Long, PolyORB.Types.Float);

   function To_Double_Buf is
      new Ada.Unchecked_Conversion
        (PolyORB.Types.Double, Double_Buf);

   function To_Double is
      new Ada.Unchecked_Conversion
        (Double_Buf, PolyORB.Types.Double);

   --   function To_Long_Double_Buf is
   --      new Ada.Unchecked_Conversion
   --       (PolyORB.Types.Long_Double, Long_Double_Buf);
   --   function To_Long_Double is
   --      new Ada.Unchecked_Conversion
   --       (Long_Double_Buf, PolyORB.Types.Long_Double);

   --  Internal utility functions

   -----------------
   -- Encapsulate --
   -----------------

   function Encapsulate (Buffer : access Buffer_Type) return Encapsulation  is
   begin
      return Encapsulation'(To_Stream_Element_Array (Buffer));
   end Encapsulate;

   -------------------------
   -- Start_Encapsulation --
   -------------------------

   procedure Start_Encapsulation (Buffer : access Buffer_Type) is
   begin
      Set_Initial_Position (Buffer, 0);
      Marshall
        (Buffer,
         PolyORB.Types.Boolean
         (Endianness (Buffer) = Little_Endian));
      --  An encapsulation starts with a Boolean value
      --  which is True if the remainder of the buffer is
      --  Little_Endian, and False otherwise.
   end Start_Encapsulation;

   --  Internal utility functions

   -----------------
   -- Decapsulate --
   -----------------

   procedure Decapsulate
     (Octets : access Encapsulation;
      Buffer : access Buffer_Type)
   is
      Endianness : Endianness_Type;
   begin
      if PolyORB.Types.Boolean'Val
        (PolyORB.Types.Octet (Octets (Octets'First))) then
         Endianness := Little_Endian;
      else
         Endianness := Big_Endian;
      end if;

      Initialize_Buffer
        (Buffer               => Buffer,
         Size                 => Octets'Length - 1,
         Data                 => Octets (Octets'First + 1)'Address,
         Endianness           => Endianness,
         Initial_CDR_Position => 1);
   end Decapsulate;

   --  procedure Marshall_From_Any
   --    (Buffer          : access Buffer_Type;
   --     Data            : PolyORB.Any.Any;
   --     Marshalled_List : in out False_List;
   --     Depth           : PolyORB.Types.Long)
   --  is
   --     Success : Boolean;
   --  begin
   --     Success := Marshall_Indirection (Buffer, Data, Already_Marshalled);
   --     if not Success then
   --        declare
   --           Aggregate_Nb, Member_Nb : PolyORB.Types.Unsigned_Long;
   --           Value : PolyORB.Any.Any;
   --        begin
   --           pragma Debug
   --             (C, O ("Marshall_From_Any : dealing with a value"));
   --           Marshall (Buffer, Default_Value_Tag);

   --           Aggregate_Nb := PolyORB.Any.Get_Aggregate_Count(Data);
   --           Member_Nb := (Aggregate_Nb - 3) / 3;
   --           I := 5;
   --           J := 0;
   --           while (J < Member_Nb) loop
   --              Member_Value := PolyORB.Any.Get_Aggregate_Element
   --                (Data,
   --                 PolyORB.Any.TypeCode.Member_Type (Data_Type, I + 3 * J),
   --                 J);
   --              declare
   --                 Member_Type : constant PolyORB.Any.TypeCode.Local_Ref
   --                    := PolyORB.Any.Get_Unwound_Type (Member_Value);
   --              begin
   --                 case PolyORB.Any.TypeCode.Kind (Member_Type) is
   --                    when Tk_Value =>
   --                       Marshall_From_Any
   --                         (Buffer, To_Real (Value),
   --                          Marshalled_List, Depth + 1);
   --                    when others =>
   --                       Marshall_From_Any (Buffer, Member_Value);
   --                 end case;
   --              end;
   --           end loop;
   --        end;
   --     end if;
   --  end Marshall_From_Any;

   --------------
   -- Marshall --
   --------------

   --  Marshall-by-copy subprograms for all elementary types.

   --  Marshalling of a Boolean

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Boolean)
   is
   begin
      pragma Debug (C, O ("Marshall (Boolean) : enter"));
      Marshall
        (Buffer, PolyORB.Types.Octet'(PolyORB.Types.Boolean'Pos (Data)));
      pragma Debug (C, O ("Marshall (Boolean) : end"));
   end Marshall;

   --  Marshalling of a Character

   procedure Marshall_Latin_1_Char
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Char)
   is
   begin
      pragma Debug (C, O ("Marshall (Char) : enter"));
      Marshall (Buffer, PolyORB.Types.Octet'(PolyORB.Types.Char'Pos (Data)));
      pragma Debug (C, O ("Marshall (Char) : end"));
   end Marshall_Latin_1_Char;

   --  Marshalling of an Octet

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Octet)
   is
   begin
      pragma Debug (C, O ("Marshall (Octet) : enter"));
      Align_Marshall_Copy (Buffer, (1 => Stream_Element
                           (PolyORB.Types.Octet'(Data))), 1);
      pragma Debug (C, O ("Marshall (Octet) : end"));
   end Marshall;

   --  Marshalling of an Unsigned Short

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Unsigned_Short)
   is
   begin
      pragma Debug (C, O ("Marshall (UShort) : enter"));
      Align_Marshall_Big_Endian_Copy
        (Buffer,
         Stream_Element_Array'(Stream_Element (Data / 256),
          Stream_Element (Data mod 256)),
         2);
      pragma Debug (C, O ("Marshall (UShort) : end"));
   end Marshall;

   --  Marshalling of an Unsigned Long

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Unsigned_Long)
   is
   begin
      pragma Debug (C, O ("Marshall (ULong) : enter"));
      Align_Marshall_Big_Endian_Copy
        (Buffer,
          Stream_Element_Array'(Stream_Element (Data / 256**3),
          Stream_Element ((Data / 256**2) mod 256),
          Stream_Element ((Data / 256) mod 256),
          Stream_Element (Data mod 256)),
         4);
      pragma Debug (C, O ("Marshall (ULong) : end"));
   end Marshall;

   --  Marshalling of an Unsigned Long Long

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Unsigned_Long_Long)
   is
   begin
      pragma Debug (C, O ("Marshall (ULongLong) : enter"));
      Align_Marshall_Big_Endian_Copy
        (Buffer,
         Stream_Element_Array'(Stream_Element (Data / 256**7),
          Stream_Element ((Data / 256**6) mod 256),
          Stream_Element ((Data / 256**5) mod 256),
          Stream_Element ((Data / 256**4) mod 256),
          Stream_Element ((Data / 256**3) mod 256),
          Stream_Element ((Data / 256**2) mod 256),
          Stream_Element ((Data / 256) mod 256),
          Stream_Element (Data mod 256)),
         8);
      pragma Debug (C, O ("Marshall (ULongLong) : end"));
   end Marshall;

   --  Marshalling of a Long Long

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Long_Long)
   is
   begin
      pragma Debug (C, O ("Marshall (LongLong) : enter"));
      Marshall (Buffer, To_Unsigned_Long_Long (Data));
      pragma Debug (C, O ("Marshall (LongLong) : end"));
   end Marshall;

   --  Marshalling of a Long

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Long)
   is
   begin
      pragma Debug (C, O ("Marshall (Long) : enter"));
      Marshall (Buffer, To_Unsigned_Long (Data));
      pragma Debug (C, O ("Marshall (Long) : end"));
   end Marshall;

   --  Marshalling of a Short

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Short)
   is
   begin
      pragma Debug (C, O ("Marshall (Short) : enter"));
      Marshall (Buffer, To_Unsigned_Short (Data));
      pragma Debug (C, O ("Marshall (Short) : end"));
   end Marshall;

   --  Marshalling of a Float

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Float)
   is
   begin
      pragma Debug (C, O ("Marshall (Float) : enter"));
      Marshall (Buffer, To_Unsigned_Long (Data));
      pragma Debug (C, O ("Marshall (Float) : end"));
   end Marshall;

   --  Marshalling of a Double

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Double)
   is
      Buf : constant Double_Buf := To_Double_Buf (Data);

   begin
      pragma Debug (C, O ("Marshall (Double): enter, Data = "
                       & PolyORB.Types.Double'Image (Data)));
      Align_Marshall_Host_Endian_Copy (Buffer, Buf, 8);
      pragma Debug (C, O ("Marshall (Double): end"));
   end Marshall;

   --  Marshalling of a Long Double

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Long_Double)
   is
      --  FIXME LONG DOUBLE
      --   Buf : Long_Double_Buf := To_Long_Double_Buf (Data);
   begin
      raise Program_Error;
      --      pragma Debug (C, O ("Marshall (LongDouble) : enter"));
      --      Align_Marshall_Host_Endian_Copy (Buffer, Buf, 8);
      --      pragma Debug (C, O ("Marshall (LongDouble) : end"));
   end Marshall;

   --  Marshalling of a Standard String

   procedure Marshall_Latin_1_String
     (Buffer : access Buffer_Type;
      Data   : Standard.String)
   is
      Str : Stream_Element_Array (1 .. Data'Length);
      for Str'Address use Data'Address;
      pragma Import (Ada, Str);

   begin
      pragma Debug (C, O ("Marshall (String) : enter"));

      Marshall (Buffer, PolyORB.Types.Unsigned_Long'(Data'Length + 1));
      Align_Marshall_Copy (Buffer, Str);
      Marshall_Latin_1_Char (Buffer, PolyORB.Types.Char (ASCII.Nul));

      pragma Debug (C, O ("Marshall (String) : end"));
   end Marshall_Latin_1_String;

   --  Marshalling of a PolyORB.Types.String

   procedure Marshall_Latin_1_String
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.String)
   is
   begin
      pragma Debug (C, O ("Marshall (PolyORB.Types.String) : enter"));
      Marshall_Latin_1_String
        (Buffer, PolyORB.Types.To_Standard_String (Data));
      pragma Debug (C, O ("Marshall (PolyORB.Types.String) : end"));
   end Marshall_Latin_1_String;

   --  Marshalling of an Identifier

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.Identifier)
   is
   begin
      pragma Debug (C, O ("Marshall (Identifier) : enter"));
      Marshall_Latin_1_String (Buffer, PolyORB.Types.String (Data));
      pragma Debug (C, O ("Marshall (Identifier) : end"));
   end Marshall;

   --  Marshalling of a Repository Identifier

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Types.RepositoryId)
   is
   begin
      pragma Debug (C, O ("Marshall (RepositoryId) : enter"));
      Marshall_Latin_1_String (Buffer, PolyORB.Types.String (Data));
      pragma Debug (C, O ("Marshall (RepositoryId) : end"));
   end Marshall;

   --  Marshalling of a Value Modifier type (short)

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Any.ValueModifier)
   is
   begin
      pragma Debug (C, O ("Marshall (ValueModifier) : enter"));
      Marshall (Buffer, PolyORB.Types.Short (Data));
      pragma Debug (C, O ("Marshall (ValueModifier) : end"));
   end Marshall;

   --  Marshalling of a Visibility Type (short)

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.Any.Visibility)
   is
   begin
      pragma Debug (C, O ("Marshall (Visibility) : enter"));
      Marshall (Buffer, PolyORB.Types.Short (Data));
      pragma Debug (C, O ("Marshall (Visibility) : end"));
   end Marshall;

   --  Marshall a sequence of octets

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : Stream_Element_Array)
   is
   begin
      pragma Debug (C, O ("Marshall (Encapsulation) : enter"));
      Marshall (Buffer, PolyORB.Types.Unsigned_Long (Data'Length));
      Align_Marshall_Copy (Buffer, Data);
      pragma Debug (C, O ("Marshall (Encapsulation) : end"));
   end Marshall;

   --  procedure Marshall
   --    (Buffer : access Buffer_Type;
   --     Data   : Encapsulation) is
   --  begin
   --     pragma Debug (C, O ("Marshall (Encapsulation) : enter"));
   --     Marshall (Buffer, PolyORB.Types.Unsigned_Long (Data'Length));
   --     for I in Data'Range loop
   --        Marshall (Buffer, PolyORB.Types.Octet (Data (I)));
   --     end loop;
   --     pragma Debug (C, O ("Marshall (Encapsulation) : end"));
   --  end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : PolyORB.References.Ref'Class) is
   begin
      --  !!!!!!!!!!!!!!!!!
      --  FIXME: I've just noticed that abstract interfaces must be
      --  encoded as unions
      --  with a boolean discriminator, cf spec and change code below.
      --  !!!!!!!!!!!!!!!!!

      --  ValueTypes are not implemented in PolyORB.

--      --  1. if Data is a valuetype, call the valuetype marshalling function
--      if Data in CORBA.Value.Base'Class then
--  --         PolyORB.CORBA_P.Value.Stream.Marshall
--  --           (Buffer, PolyORB.Types.Value.Base'Class (Data));
--         raise PolyORB.Not_Implemented;

--         --  2. check if Data is a nil ref, raise marshall if true
--      elsif CORBA.AbstractBase.Is_Nil (Data) then
--         raise Constraint_Error;

--         --  3. If Data is an abstract interface and the referenced object is
--         --     a valuetype, then call the valuetype marshalling function.
--         --  In practice, just check if the referenced object is a valuetype.
--      elsif CORBA.AbstractBase.Object_Of (Data).all
--        in CORBA.Value.Impl_Base'Class then
--         --  PolyORB.CORBA_P.Value.Stream.Marshall (Buffer,
--         --                             Data);
--         raise PolyORB.Not_Implemented;
--         --  Not implemented yet

--         --  4. Call the interface marshalling function
--      else
      References.IOR.Marshall_IOR (Buffer, References.Ref (Data));
--      end if;
   end Marshall;

   ---------------------------------------------------
   -- Marshall-by-reference subprograms             --
   -- (for elementary types, these are placeholders --
   -- that actually perform marshalling by copy.    --
   ---------------------------------------------------

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Octet)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Boolean)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Short)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Unsigned_Short)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Long)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Long_Long)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Unsigned_Long)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Unsigned_Long_Long)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Float)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Double)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Long_Double)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.Identifier)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Types.RepositoryId)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Any.ValueModifier)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access PolyORB.Any.Visibility)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   procedure Marshall
     (Buffer : access Buffer_Type;
      Data   : access Stream_Element_Array)
   is
   begin
      Marshall (Buffer, Data.all);
   end Marshall;

   ------------------------------------
   -- Unmarshall-by-copy subprograms --
   ------------------------------------

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Boolean
   is
   begin
      pragma Debug (C, O ("Unmarshall (Boolean) : enter & end"));
      return PolyORB.Types.Boolean'Val
        (PolyORB.Types.Octet'(Unmarshall (Buffer)));
   end Unmarshall;

   function Unmarshall_Latin_1_Char
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Char
   is
   begin
      pragma Debug (C, O ("Unmarshall (Char) : enter & end"));
      return PolyORB.Types.Char'Val
        (PolyORB.Types.Octet'(Unmarshall (Buffer)));
   end Unmarshall_Latin_1_Char;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Octet
   is
      Result : constant Stream_Element_Array
        := Align_Unmarshall_Copy (Buffer, 1, 1);

   begin
      pragma Debug (C, O ("Unmarshall (Octet) : enter & end"));
      return PolyORB.Types.Octet (Result (Result'First));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type) return PolyORB.Types.Unsigned_Short
   is
      package FSU is new Fixed_Size_Unmarshall (Size => 2, Alignment => 2);
      Z : constant FSU.AZ := FSU.Align_Unmarshall (Buffer);
   begin
      if Endianness (Buffer) = Big_Endian then
         return Types.Unsigned_Short (Z (0)) * 256
              + Types.Unsigned_Short (Z (1));
      else
         return Types.Unsigned_Short (Z (1)) * 256
              + Types.Unsigned_Short (Z (0));
      end if;
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type) return PolyORB.Types.Unsigned_Long
   is
      package FSU is new Fixed_Size_Unmarshall (Size => 4, Alignment => 4);
      Z : constant FSU.AZ := FSU.Align_Unmarshall (Buffer);
   begin
      if Endianness (Buffer) = Big_Endian then
         return Types.Unsigned_Long (Z (0)) * 256**3
              + Types.Unsigned_Long (Z (1)) * 256**2
              + Types.Unsigned_Long (Z (2)) * 256
              + Types.Unsigned_Long (Z (3));
      else
         return Types.Unsigned_Long (Z (3)) * 256**3
              + Types.Unsigned_Long (Z (2)) * 256**2
              + Types.Unsigned_Long (Z (1)) * 256
              + Types.Unsigned_Long (Z (0));
      end if;
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type) return PolyORB.Types.Unsigned_Long_Long
   is
      package FSU is new Fixed_Size_Unmarshall (Size => 8, Alignment => 8);
      Z : constant FSU.AZ := FSU.Align_Unmarshall (Buffer);
   begin
      if Endianness (Buffer) = Big_Endian then
         return Types.Unsigned_Long_Long (Z (0)) * 256**7
              + Types.Unsigned_Long_Long (Z (1)) * 256**6
              + Types.Unsigned_Long_Long (Z (2)) * 256**5
              + Types.Unsigned_Long_Long (Z (3)) * 256**4
              + Types.Unsigned_Long_Long (Z (4)) * 256**3
              + Types.Unsigned_Long_Long (Z (5)) * 256**2
              + Types.Unsigned_Long_Long (Z (6)) * 256
              + Types.Unsigned_Long_Long (Z (7));
      else
         return Types.Unsigned_Long_Long (Z (7)) * 256**7
              + Types.Unsigned_Long_Long (Z (6)) * 256**6
              + Types.Unsigned_Long_Long (Z (5)) * 256**5
              + Types.Unsigned_Long_Long (Z (4)) * 256**4
              + Types.Unsigned_Long_Long (Z (3)) * 256**3
              + Types.Unsigned_Long_Long (Z (2)) * 256**2
              + Types.Unsigned_Long_Long (Z (1)) * 256
              + Types.Unsigned_Long_Long (Z (0));
      end if;
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type) return PolyORB.Types.Long_Long
   is
   begin
      pragma Debug (C, O ("Unmarshall (LongLong) : enter & end"));
      return To_Long_Long (Unmarshall (Buffer));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Long
   is
   begin
      pragma Debug (C, O ("Unmarshall (Long) : enter & end"));
      return To_Long (Unmarshall (Buffer));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Short
   is
   begin
      pragma Debug (C, O ("Unmarshall (Short) : enter & end"));
      return To_Short (Unmarshall (Buffer));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Float
   is
   begin
      pragma Debug (C, O ("Unmarshall (Float) : enter & end"));
      return To_Float (Unmarshall (Buffer));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Double
   is
      Octets : constant Stream_Element_Array
        := Align_Unmarshall_Host_Endian_Copy (Buffer, 8, 8);

   begin
      pragma Debug (C, O ("Unmarshall (Double): enter & end"));
      return To_Double (Double_Buf (Octets));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Long_Double
   is
      --  Octets : constant Stream_Element_Array :=
      --  Align_Unmarshall_Host_Endian_Copy (Buffer, 12, 8);
   begin
      --  pragma Debug (C, O ("Unmarshall (LongDouble) : enter & end"));
      --  return To_Long_Double (Long_Double_Buf (Octets));
      raise Program_Error;
      pragma Warnings (Off);
      return Unmarshall (Buffer);
      --  "Possible infinite recursion".
      pragma Warnings (On);
   end Unmarshall;

   function Unmarshall_Latin_1_String
     (Buffer : access Buffer_Type)
     return Standard.String
   is
      Length : constant PolyORB.Types.Unsigned_Long
        := Unmarshall (Buffer);
      Equiv  : String (1 .. Natural (Length) - 1);

   begin
      pragma Debug (C, O ("Unmarshall (String): enter"));
      pragma Debug (C, O ("Unmarshall (String): length is " &
                    PolyORB.Types.Unsigned_Long'Image (Length)));

      if Length = 0 then
         return "";
      end if;

      for J in Equiv'Range loop
         Equiv (J) := Character'Val
           (PolyORB.Types.Char'Pos (Unmarshall_Latin_1_Char (Buffer)));
      end loop;

      if Character'Val
           (PolyORB.Types.Char'Pos (Unmarshall_Latin_1_Char (Buffer)))
        /= ASCII.Nul
      then
         raise Constraint_Error;
      end if;

      pragma Debug (C, O ("Unmarshall (String): -> " & Equiv));

      return Equiv;
   end Unmarshall_Latin_1_String;

   function Unmarshall_Latin_1_String
     (Buffer : access Buffer_Type)
     return PolyORB.Types.String
   is
   begin
      return
        PolyORB.Types.To_PolyORB_String (Unmarshall_Latin_1_String (Buffer));
   end Unmarshall_Latin_1_String;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.Identifier
   is
   begin
      pragma Debug (C, O ("Unmarshall (Identifier) : enter & end"));
      return PolyORB.Types.Identifier
        (PolyORB.Types.String'(Unmarshall_Latin_1_String (Buffer)));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Types.RepositoryId
   is
   begin
      pragma Debug (C, O ("Unmarshall (RepositoryId) : enter & end"));
      return PolyORB.Types.RepositoryId
        (PolyORB.Types.String'(Unmarshall_Latin_1_String (Buffer)));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Any.ValueModifier
   is
   begin
      pragma Debug (C, O ("Unmarshall (ValueModifier) : enter & end"));
      return PolyORB.Any.ValueModifier
        (PolyORB.Types.Short'(Unmarshall (Buffer)));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.Any.Visibility
   is
   begin
      pragma Debug (C, O ("Unmarshall (Visibility) : enter & end"));
      return PolyORB.Any.Visibility
        (PolyORB.Types.Short'(Unmarshall (Buffer)));
   end Unmarshall;

   --   function Unmarshall (Buffer : access Buffer_Type)
   --     return Encapsulation
   --   is
   --      Length : constant PolyORB.Types.Unsigned_Long
   --        := Unmarshall (Buffer);
   --   begin
   --      pragma Debug (C, O ("Unmarshall (Encapsulation):
   --                length is" & Length'Img));
   --      declare
   --         E : Encapsulation (1 .. Stream_Element_Offset(Length));
   --      begin
   --         for I in E'Range loop
   --            E (I) := Stream_Element(PolyORB.Types.Octet'
   --                (Unmarshall (Buffer)));
   --         end loop;
   --         pragma Debug (C, O ("Unmarshall (Encapsulation): end"));
   --         return E;
   --      end;
   --   end Unmarshall;

   procedure Unmarshall
     (Buffer : access Buffer_Type;
      Data   : in out PolyORB.References.Ref'Class)
   is
      use PolyORB.References;
      use PolyORB.References.IOR;

      IOR : constant Ref := Unmarshall_IOR (Buffer);

   begin
      PolyORB.References.Set (Data, Entity_Of (IOR));
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return PolyORB.References.Ref
   is
      Result : PolyORB.References.Ref;

   begin
      Unmarshall (Buffer, Result);
      return Result;
   end Unmarshall;

   function Unmarshall
     (Buffer : access Buffer_Type)
     return Stream_Element_Array
   is
      Length : constant PolyORB.Types.Unsigned_Long := Unmarshall (Buffer);

   begin
      pragma Debug (C, O ("Unmarshall (Encapsulation): length" & Length'Img));
      declare
         E : Stream_Element_Array (1 .. Stream_Element_Offset (Length));
      begin
         for J in E'Range loop
            E (J) := Stream_Element
                     (PolyORB.Types.Octet'(Unmarshall (Buffer)));
         end loop;
         pragma Debug (C, O ("Unmarshall (Encapsulation): end"));
         return E;
      end;
   end Unmarshall;

   -----------------
   -- Fixed_Point --
   -----------------

   package body Fixed_Point is

      Max_Digits : constant := 31;
      --  31 is the maximum number of digits for a fixed type

      --------------
      -- Marshall --
      --------------

      procedure Marshall
        (Buffer : access Buffer_Type;
         Data   : access F)
      is
      begin
         Marshall (Buffer, Data.all);
      end Marshall;

      procedure Marshall
        (Buffer : access Buffer_Type;
         Data   : F)
      is
      begin
         Align_Marshall_Copy (Buffer, Fixed_To_Octets (Data), 1);
      end Marshall;

      ----------------
      -- Unmarshall --
      ----------------

      function Unmarshall
        (Buffer : access Buffer_Type)
        return F
      is
         Octets : Stream_Element_Array (1 .. Max_Digits) := (others => 0);
         J : Stream_Element_Count := 0;

      begin
         loop
            J := J + 1;
            Octets (J) := Stream_Element
              (PolyORB.Types.Octet'(Unmarshall (Buffer)));
            exit when Octets (J) mod 16 > 9;
         end loop;

         return Octets_To_Fixed (Octets (1 .. J));
      end Unmarshall;

      package FPC is new PolyORB.Fixed_Point.Fixed_Point_Conversion (F);

      ---------------------
      -- Fixed_To_Octets --
      ---------------------

      function Fixed_To_Octets (Data : F) return Stream_Element_Array is
         use PolyORB.Fixed_Point;
         use FPC;

         N : constant PolyORB.Fixed_Point.Nibbles := Fixed_To_Nibbles (Data);
         B : Stream_Element_Array (0 .. N'Length / 2 - 1);

      begin
         for J in B'Range loop
            B (J) := Stream_Element (N (N'First + 2 * Integer (J))) * 16
                   + Stream_Element (N (N'First + 2 * Integer (J) + 1));
         end loop;
         return B;
      end Fixed_To_Octets;

      ---------------------
      -- Octets_To_Fixed --
      ---------------------

      function Octets_To_Fixed (Octets : Stream_Element_Array) return F is
         use PolyORB.Fixed_Point;
         use FPC;

         N : PolyORB.Fixed_Point.Nibbles (0 .. Octets'Length * 2 - 1);

      begin
         for J in Octets'Range loop
            N (2 * Integer (J - Octets'First))
              := Nibble (Octets (J) / 16);
            N (2 * Integer (J - Octets'First) + 1)
              := Nibble (Octets (J) mod 16);
         end loop;
         return Nibbles_To_Fixed (N);
      end Octets_To_Fixed;

   end Fixed_Point;

end PolyORB.Representations.CDR.Common;
