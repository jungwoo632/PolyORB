------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                      A W S . D I S P A T C H E R S                       --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2000-2006, Free Software Foundation, Inc.          --
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

--  This package provides a service to build Callbacks which can support
--  user's data. It is possible to build a new dispatcher by inheriting the
--  handler type and to provides the Dispatch routine.

with Ada.Finalization;

with AWS.Response;
with AWS.Status;

package AWS.Dispatchers is

   type Handler is abstract new Ada.Finalization.Controlled with private;

   procedure Initialize (Dispatcher : in out Handler);
   procedure Adjust     (Dispatcher : in out Handler);
   procedure Finalize   (Dispatcher : in out Handler);
   --  Initialize/Adjust/Finalize is doing the reference counting, children
   --  should just call these routines if possible. It is possible to know if
   --  no more object are referenced by calling Ref_Counter below.

   function Dispatch
     (Dispatcher : Handler;
      Request    : Status.Data)
     return Response.Data is abstract;
   --  Call the appropriate inherited dispatcher

   function Ref_Counter (Dispatcher : Handler) return Natural;
   --  Returns the reference counter for Handler. If 0 is returned then this
   --  object is not referenced anymore, it is safe to deallocate ressources.

   type Handler_Class_Access is access all Handler'Class;

   procedure Free (Dispatcher : in out Handler_Class_Access);
   pragma Inline (Free);

private

   type Natural_Access is access all Natural;

   type Handler is abstract new Ada.Finalization.Controlled with record
      Ref_Counter : Natural_Access := null;
   end record;

end AWS.Dispatchers;