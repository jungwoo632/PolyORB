------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                COSTYPEDEVENTCOMM.TYPEDPUSHCONSUMER.IMPL                  --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2003-2006, Free Software Foundation, Inc.          --
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

with CORBA.Impl;

with CosEventChannelAdmin;
with CosEventChannelAdmin.ProxyPushSupplier;

with CosEventComm.PushConsumer.Skel;

with CosTypedEventChannelAdmin.TypedEventChannel;

with PolyORB.CORBA_P.Server_Tools;
with PolyORB.Log;
with PolyORB.Tasking.Mutexes;
with PolyORB.Tasking.Semaphores;

with CosTypedEventComm.TypedPushConsumer.Skel;
pragma Warnings (Off, CosTypedEventComm.TypedPushConsumer.Skel);

package body CosTypedEventComm.TypedPushConsumer.Impl is

   use CosEventChannelAdmin;

   use CosTypedEventChannelAdmin;

   use PortableServer;

   use PolyORB.CORBA_P.Server_Tools;
   use PolyORB.Tasking.Mutexes;
   use PolyORB.Tasking.Semaphores;

   use PolyORB.Log;
   package L is new PolyORB.Log.Facility_Log ("typedpushconsumer");
   procedure O (Message : Standard.String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;
   pragma Unreferenced (C); --  For conditional pragma Debug

   type Typed_Push_Consumer_Record is record
      This    : Object_Ptr;
      Peer    : ProxyPushSupplier.Ref;
      Empty   : Boolean;
      Event   : CORBA.Any;
      Semaphore : Semaphore_Access;
      Uses_Interface : TypedEventChannel.Impl.Interface_Ptr;
   end record;

   ---------------------------
   -- Ensure_Initialization --
   ---------------------------

   procedure Ensure_Initialization;
   pragma Inline (Ensure_Initialization);
   --  Ensure that the Mutexes are initialized

   T_Initialized : Boolean := False;
   Self_Mutex : Mutex_Access;

   procedure Ensure_Initialization is
   begin
      if not T_Initialized then
         Create (Self_Mutex);
         T_Initialized := True;
      end if;
   end Ensure_Initialization;

   ------------------------
   -- Get_Typed_Consumer --
   ------------------------

   function Get_Typed_Consumer
   (Self : access Object)
      return CORBA.Object.Ref
   is
      InterfaceObject : CORBA.Impl.Object_Ptr;
      Ref : CORBA.Object.Ref;
   begin
      pragma Debug (O ("get the mutually agreed Interface from" &
                        "TypedPushConsumer"));

      Ensure_Initialization;

      Enter (Self_Mutex);
      InterfaceObject := Self.X.Uses_Interface.all;
      Leave (Self_Mutex);

      Initiate_Servant (PortableServer.Servant (InterfaceObject), Ref);
      return Ref;
   end Get_Typed_Consumer;

   ----------
   -- Push --
   ----------

   procedure Push
     (Self : access Object;
      Data : CORBA.Any)
   is
      pragma Warnings (Off); --  WAG:3.14
      pragma Unreferenced (Self, Data);
      pragma Warnings (On);  --  WAG:3.14
   begin
      pragma Debug (O ("trying to push new data to Typed PushConsumer"));
      pragma Debug (O ("no need to use generic push in Typed PushConsumer"));

      Ensure_Initialization;

      --  No need to implement push in TypedPushConsumer
      raise Program_Error;
   end Push;

   ------------------------------
   -- Disconnect_Push_Consumer --
   ------------------------------

   procedure Disconnect_Push_Consumer
     (Self : access Object)
   is
      Peer    : ProxyPushSupplier.Ref;
      Nil_Ref : ProxyPushSupplier.Ref;

   begin
      pragma Debug (O ("disconnect typedpush consumer"));

      Ensure_Initialization;

      Enter (Self_Mutex);
      Peer        := Self.X.Peer;
      Self.X.Peer := Nil_Ref;
      Leave (Self_Mutex);

      V (Self.X.Semaphore);

      if not ProxyPushSupplier.Is_Nil (Peer) then
         ProxyPushSupplier.disconnect_push_supplier (Peer);
      end if;
   end Disconnect_Push_Consumer;

   ------------
   -- Create --
   ------------

   function Create
      return Object_Ptr
   is
      Consumer : Object_Ptr;
      My_Ref   : TypedPushConsumer.Ref;

   begin
      pragma Debug (O ("create typedpushconsumer"));

      Consumer         := new Object;
      Consumer.X       := new Typed_Push_Consumer_Record;
      Consumer.X.This  := Consumer;
      Consumer.X.Empty := True;
      Create (Consumer.X.Semaphore);
      Initiate_Servant (Servant (Consumer), My_Ref);
      return Consumer;
   end Create;

   ----------------------
   -- SetInterface_Ptr --
   ----------------------

   procedure SetInterface_Ptr
     (Self  : access Object;
     I_Ptr  : TypedEventChannel.Impl.Interface_Ptr) is
   begin
      pragma Debug (O ("set the supported interface pointer in" &
                       "typedpushconsumer"));

      Ensure_Initialization;

      Enter (Self_Mutex);
      Self.X.Uses_Interface := I_Ptr;
      Leave (Self_Mutex);
   end SetInterface_Ptr;

end CosTypedEventComm.TypedPushConsumer.Impl;