------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                         T E S T _ S U P P O R T                          --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2005 Free Software Foundation, Inc.             --
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
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Streams;
with Ada.Text_IO;

with CORBA.Object;
with CORBA.ORB;
with CORBA.Policy;
with PortableServer.POA.Helper;

with Test.Echo.Helper;
with Test.Echo.Impl;
with Test.Factory.Impl;

package body Test_Support is

   function To_ObjectId (Item : in Wide_String) return PortableServer.ObjectId;

   My_POA : PortableServer.POA.Ref;

   ---------------
   -- Incarnate --
   ---------------

   function Incarnate
     (Self    : in Activator;
      Oid     : in PortableServer.ObjectId;
      Adapter : in PortableServer.POA_Forward.Ref)
     return PortableServer.Servant
   is
      pragma Unreferenced (Self);

      Srv : constant Test.Echo.Impl.Object_Ptr := new Test.Echo.Impl.Object;

   begin
      PortableServer.POA.Activate_Object_With_Id
       (PortableServer.POA.Helper.To_Ref (Adapter),
        Oid,
        PortableServer.Servant (Srv));

      return PortableServer.Servant (Srv);
   end Incarnate;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Root_POA : PortableServer.POA.Ref
        := PortableServer.POA.Helper.To_Ref
            (CORBA.ORB.Resolve_Initial_References
              (CORBA.ORB.To_CORBA_String ("RootPOA")));

      Policies : CORBA.Policy.PolicyList;

   begin
      CORBA.Policy.IDL_Sequence_Policy.Append
       (Policies,
        CORBA.Policy.Ref
         (PortableServer.POA.Create_Lifespan_Policy
           (PortableServer.PERSISTENT)));
      CORBA.Policy.IDL_Sequence_Policy.Append
       (Policies,
        CORBA.Policy.Ref
         (PortableServer.POA.Create_Id_Assignment_Policy
           (PortableServer.USER_ID)));
      CORBA.Policy.IDL_Sequence_Policy.Append
       (Policies,
        CORBA.Policy.Ref
         (PortableServer.POA.Create_Implicit_Activation_Policy
           (PortableServer.NO_IMPLICIT_ACTIVATION)));
      CORBA.Policy.IDL_Sequence_Policy.Append
       (Policies,
        CORBA.Policy.Ref
         (PortableServer.POA.Create_Request_Processing_Policy
           (PortableServer.USE_SERVANT_MANAGER)));

      My_POA :=
        PortableServer.POA.Ref
         (PortableServer.POA.Create_POA
           (Root_POA,
            CORBA.To_CORBA_String ("Ring_POA"),
            PortableServer.POA.Get_The_POAManager (Root_POA),
            Policies));

      PortableServer.POA.Set_Servant_Manager (My_POA, new Activator);

      declare
         Srv : constant Test.Factory.Impl.Object_Ptr
           := new Test.Factory.Impl.Object;
         Ref : CORBA.Object.Ref
           := PortableServer.POA.Servant_To_Reference
               (Root_POA,
                PortableServer.Servant (Srv));
      begin
         Ada.Text_IO.Put_Line
          (CORBA.To_Standard_String (CORBA.ORB.Object_To_String (Ref)));
      end;
   end Initialize;

   -----------------
   -- Preallocate --
   -----------------

   procedure Preallocate (Count : in Natural) is
   begin
      for J in 1 .. Count loop
         declare
            Srv : constant Test.Echo.Impl.Object_Ptr
              := new Test.Echo.Impl.Object;
         begin
            PortableServer.POA.Activate_Object_With_Id
             (My_POA,
              To_ObjectId (Integer'Wide_Image (J)),
              PortableServer.Servant (Srv));
         end;
      end loop;
   end Preallocate;

   -----------------
   -- To_ObjectId --
   -----------------

   function To_ObjectId
     (Item : in Wide_String)
      return PortableServer.ObjectId
   is
      use Ada.Streams;

      Result : PortableServer.ObjectId (1 .. Item'Length * 2);
   begin
      for J in Item'Range loop
         Result (Result'First + 2 * Stream_Element_Offset (J - Item'First))
           := Stream_Element (Wide_Character'Pos (Item (J)) / 256);
         Result (Result'First + 2 * Stream_Element_Offset (J - Item'First) + 1)
           := Stream_Element (Wide_Character'Pos (Item (J)) mod 256);
      end loop;

      return Result;
   end To_ObjectId;

   -------------------------
   -- To_Object_Reference --
   -------------------------

   function To_Object_Reference (Id : in Natural) return Test.Echo.Ref is
   begin
      return
        Test.Echo.Helper.To_Ref
         (PortableServer.POA.Create_Reference_With_Id
           (My_POA,
            To_ObjectId (Natural'Wide_Image (Id)),
            CORBA.To_CORBA_String (Test.Echo.Repository_Id)));
   end To_Object_Reference;

end Test_Support;
