------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--     P O L Y O R B . P R O T O C O L S . G I O P . G I O P _ 1 _ 1        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                Copyright (C) 2001 Free Software Fundation                --
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
--              PolyORB is maintained by ENST Paris University.             --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with Ada.Streams; use Ada.Streams;

with PolyORB.Buffers;
with PolyORB.References;
with PolyORB.References.IOR;
with PolyORB.Binding_Data;
with PolyORB.Types;

package PolyORB.Protocols.GIOP.GIOP_1_1  is

   pragma Elaborate_Body;

   type Service_Id_Array is array (Integer range <>) of ServiceId;
   Service_Context_List_1_1 : constant Service_Id_Array;

   procedure Marshall_GIOP_Header
     (Buffer        : access Buffers.Buffer_Type;
      Message_Type  : in Msg_Type;
      Message_Size  : in Stream_Element_Offset;
      --  Total message size (including GIOP header).
      Fragment_Next : in Boolean);


   procedure Marshall_Request_Message
     (Buffer                : access Buffers.Buffer_Type;
      Request_Id            : in Types.Unsigned_Long;
      Target_Profile        : in Binding_Data.Profile_Access;
      Response_Expected     : in Boolean;
      Operation             : in Requests.Operation_Id);


   procedure Marshall_Fragment
    (Buffer      : access Buffers.Buffer_Type;
     Request_Id  : in Types.Unsigned_Long);


   procedure Marshall_No_Exception
    (Buffer      : access Buffers.Buffer_Type;
     Request_Id  : in Types.Unsigned_Long);


   procedure Marshall_Exception
    (Buffer           : access Buffers.Buffer_Type;
     Request_Id       : in Types.Unsigned_Long;
     Exception_Type   : in Reply_Status_Type;
     Occurence        : in Any.Any);


   procedure Marshall_Location_Forward
    (Buffer           : access Buffers.Buffer_Type;
     Request_Id       : in  Types.Unsigned_Long;
     Forward_Ref      : in  PolyORB.References.IOR.IOR_Type);


   procedure Unmarshall_Request_Message
     (Buffer            : access Buffers.Buffer_Type;
      Request_Id        : out Types.Unsigned_Long;
      Response_Expected : out Boolean;
      Object_Key        : out Objects.Object_Id_Access;
      Operation         : out Types.String);

   procedure Unmarshall_Reply_Message
     (Buffer       : access Buffers.Buffer_Type;
      Request_Id   : out Types.Unsigned_Long;
      Reply_Status : out Reply_Status_Type);

private

   --  Explicit bounds are required in the nominal subtype
   --  in order to comply with Ravenscar restriction
   --  No_Implicit_Heap_Allocation.

   Service_Context_List_1_1 : constant Service_Id_Array (0 .. 1)
     := (0 => Transaction_Service,
         1 => Code_Sets);

end PolyORB.Protocols.GIOP.GIOP_1_1;
