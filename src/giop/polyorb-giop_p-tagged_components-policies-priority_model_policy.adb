------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--     POLYORB.GIOP_P.TAGGED_COMPONENTS.POLICIES.PRIORITY_MODEL_POLICY      --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2004-2018, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Initialization;

with PolyORB.Utils.Strings;
with PolyORB.Errors;
with PolyORB.ORB;
with PolyORB.Setup;
with PolyORB.RT_POA;
with PolyORB.RT_POA_Policies.Priority_Model_Policy;
with PolyORB.Tasking.Priorities;

package body PolyORB.GIOP_P.Tagged_Components.Policies.Priority_Model_Policy is

   Priority_Model_Policy_Type : constant := 40;
   --  Defined in RT-CORBA specifications

   ---------------------
   -- Fetch_Component --
   ---------------------

   function Fetch_Component
     (Oid : access PolyORB.Objects.Object_Id)
     return Policy_Value;

   function Fetch_Component
     (Oid : access PolyORB.Objects.Object_Id)
     return Policy_Value
   is
      use PolyORB.Errors;
      use PolyORB.ORB;
      use PolyORB.RT_POA;
      use PolyORB.RT_POA_Policies.Priority_Model_Policy;
      use PolyORB.Tasking.Priorities;
      use PolyORB.Representations.CDR.Common;

      Result : Policy_Value;
      Buffer : Buffer_Access;

      Model           : Priority_Model;
      Server_ORB_Priority : ORB_Priority;
      Server_External_Priority : External_Priority;

      Error           : PolyORB.Errors.Error_Container;

   begin
      if Object_Adapter (PolyORB.Setup.The_ORB).all
        not in PolyORB.RT_POA.RT_Obj_Adapter'Class
      then
         return Policy_Value'(P_Type => Invalid_Policy_Type, P_Value => null);
      end if;

      Buffer := new Buffer_Type;

      Get_Scheduling_Parameters
        (RT_Obj_Adapter_Access (Object_Adapter (PolyORB.Setup.The_ORB)),
         PolyORB.Objects.Object_Id_Access (Oid),
         Model,
         Server_ORB_Priority,
         Server_External_Priority,
         Error);

      if Found (Error) then
         Catch (Error);
         return Policy_Value'(P_Type => Invalid_Policy_Type, P_Value => null);
      end if;

      Start_Encapsulation (Buffer);
      Marshall (Buffer,
                PolyORB.Types.Unsigned_Long
                (Priority_Model'Pos (Model)));
      Marshall (Buffer, PolyORB.Types.Short (Server_External_Priority));

      Result := Policy_Value'(P_Type => Priority_Model_Policy_Type,
                              P_Value =>
                                new Encapsulation'(Encapsulate (Buffer)));

      Release (Buffer);

      return Result;
   end Fetch_Component;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize;

   procedure Initialize is
   begin
      Register (Fetch_Component'Access);
   end Initialize;

   use PolyORB.Initialization;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"tagged_components.policies.priority_model_policy",
       Conflicts => PolyORB.Initialization.String_Lists.Empty,
       Depends   => PolyORB.Initialization.String_Lists.Empty,
       Provides  => PolyORB.Initialization.String_Lists.Empty,
       Implicit  => False,
       Init      => Initialize'Access,
       Shutdown  => null));
end PolyORB.GIOP_P.Tagged_Components.Policies.Priority_Model_Policy;
