------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                  POLYORB.REPRESENTATIONS.CDR.GIOP_1_1                    --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2004 Free Software Foundation, Inc.             --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
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
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

with PolyORB.Representations.CDR.Common;

package body PolyORB.Representations.CDR.GIOP_1_1 is

   use PolyORB.Exceptions;
   use PolyORB.GIOP_P.Code_Sets.Converters;
   use PolyORB.Representations.CDR.Common;

   procedure Free is
     new Ada.Unchecked_Deallocation (Converter'Class, Converter_Access);

   procedure Free is
     new Ada.Unchecked_Deallocation
          (Wide_Converter'Class, Wide_Converter_Access);

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   : in     PolyORB.Types.Char;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.C_Converter /= null then
         Marshall (R.C_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Marshall_Latin_1_Char (Buffer, Data);
      end if;
   end Marshall;

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   : in     PolyORB.Types.String;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.C_Converter /= null then
         Marshall (R.C_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Marshall_Latin_1_String (Buffer, Data);
      end if;
   end Marshall;

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   : in     PolyORB.Types.Wchar;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.W_Converter /= null then
         Marshall (R.W_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Throw
           (Error,
            Marshal_E,
            System_Exception_Members'(5, Completed_No));
         --  XXX Check exception and minor code.
      end if;
   end Marshall;

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   : in     PolyORB.Types.Wide_String;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.W_Converter /= null then
         Marshall (R.W_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Throw
           (Error,
            Marshal_E,
            System_Exception_Members'(5, Completed_No));
         --  XXX Check exception and minor code.
      end if;
   end Marshall;

   -------------
   -- Release --
   -------------

   procedure Release (R : in out GIOP_1_1_CDR_Representation) is
   begin
      Free (R.C_Converter);
      Free (R.W_Converter);
   end Release;

   --------------------
   -- Set_Converters --
   --------------------

   procedure Set_Converters
     (R : in out GIOP_1_1_CDR_Representation;
      C : in     PolyORB.GIOP_P.Code_Sets.Converters.Converter_Access;
      W : in     PolyORB.GIOP_P.Code_Sets.Converters.Wide_Converter_Access)
   is
   begin
      R.C_Converter := C;
      R.W_Converter := W;
   end Set_Converters;

   ----------------
   -- Unmarshall --
   ----------------

   procedure Unmarshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   :    out PolyORB.Types.Char;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.C_Converter /= null then
         Unmarshall (R.C_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Data := Unmarshall_Latin_1_Char (Buffer);
      end if;
   end Unmarshall;

   ----------------
   -- Unmarshall --
   ----------------

   procedure Unmarshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   :    out PolyORB.Types.String;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.C_Converter /= null then
         Unmarshall (R.C_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Data := Unmarshall_Latin_1_String (Buffer);
      end if;
   end Unmarshall;

   ----------------
   -- Unmarshall --
   ----------------

   procedure Unmarshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   :    out PolyORB.Types.Wchar;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.W_Converter /= null then
         Unmarshall (R.W_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Throw
           (Error,
            Marshal_E,
            System_Exception_Members'(5, Completed_No));
         --  XXX Check exception and minor code.
      end if;
   end Unmarshall;

   ----------------
   -- Unmarshall --
   ----------------

   procedure Unmarshall
     (R      : in     GIOP_1_1_CDR_Representation;
      Buffer : access Buffers.Buffer_Type;
      Data   :    out PolyORB.Types.Wide_String;
      Error  : in out Exceptions.Error_Container)
   is
   begin
      if R.W_Converter /= null then
         Unmarshall (R.W_Converter.all, Buffer, Data, Error);
      else
         --  Backward compatibility mode

         Throw
           (Error,
            Marshal_E,
            System_Exception_Members'(5, Completed_No));
         --  XXX Check exception and minor code.
      end if;
   end Unmarshall;

end PolyORB.Representations.CDR.GIOP_1_1;