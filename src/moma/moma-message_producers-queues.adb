------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--        M O M A . M E S S A G E _ P R O D U C E R S . Q U E U E S         --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--             Copyright (C) 1999-2002 Free Software Fundation              --
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

with PolyORB.Types;
with PolyORB.Any;
with PolyORB.Any.NVList;
with PolyORB.Requests;

package body MOMA.Message_Producers.Queues is

   use PolyORB.Types;

   ---------------
   -- Get_Queue --
   ---------------

   function Get_Queue return MOMA.Destinations.Queues.Queue is
   begin
      pragma Warnings (Off);
      return Get_Queue;
      pragma Warnings (On);
   end Get_Queue;

   ----------
   -- Send --
   ----------

   procedure Send (Self    : Queue;
                   Message : PolyORB.Types.String)
   is
      Arg_Name_Mesg : PolyORB.Types.Identifier
       := PolyORB.Types.To_PolyORB_String ("Mesg");

      Argument_Mesg : PolyORB.Any.Any := PolyORB.Any.To_Any (Message);

      Operation_Name : constant Standard.String := "Publish";

      Request : PolyORB.Requests.Request_Access;
      Arg_List : PolyORB.Any.NVList.Ref;
      Result : PolyORB.Any.NamedValue;
      Result_Name : PolyORB.Types.String := To_PolyORB_String ("Result");

   begin
      PolyORB.Any.NVList.Create (Arg_List);

      PolyORB.Any.NVList.Add_Item (Arg_List,
                                   Arg_Name_Mesg,
                                   Argument_Mesg,
                                   PolyORB.Any.ARG_IN);

      Result := (Name => PolyORB.Types.Identifier (Result_Name),
                 Argument => PolyORB.Any.Get_Empty_Any (PolyORB.Any.TC_Void),
                 Arg_Modes => 0);

      PolyORB.Requests.Create_Request
        (Target    => Get_Ref (Self),
         Operation => Operation_Name,
         Arg_List  => Arg_List,
         Result    => Result,
         Req       => Request);

      PolyORB.Requests.Invoke (Request);

      --    if not PolyORB.Any.Is_Empty (Request.Exception_Info) then
      --          PolyORB.CORBA_P.Exceptions.Raise_From_Any
      --            (Request.Exception_Info);
      --       end if;

      PolyORB.Requests.Destroy_Request (Request);

   end Send;

   ----------
   -- Send --
   ----------

   procedure Send
     (Message        : MOMA.Messages.Message'Class;
      Persistent     : Boolean;
      Priority_Value : Priority;
      TTL            : Time)
   is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (Message);
      pragma Unreferenced (Persistent);
      pragma Unreferenced (Priority_Value);
      pragma Unreferenced (TTL);
      pragma Warnings (On);
      null;
   end Send;

end MOMA.Message_Producers.Queues;

