with CORBA.Policy_Values; use CORBA.Policy_Values;
with CORBA.POA_Types;     use CORBA.POA_Types;


package CORBA.Policy.Id_Assignement_Policy is

   type IdAssignementPolicy is abstract new Policy with private;
   type IdAssignementPolicy_Access is access all IdAssignementPolicy;

   procedure Ensure_Id_Creation_Capability is abstract;
   --  Case SYSTEM_ID:
   --  Does nothing;
   --  Case USER_ID:
   --  Throws a WrongPolicy exception

   procedure Ensure_Id_Origin
     (Self : in out IdAssignementPolicy_Access;
      OA   : access CORBA.POA_Types.Obj_Adapter;
      Oid  : in     Object_Id)
      is abstract;
   --  Case SYSTEM_ID:
   --  Checks that the Object_Id has been generated by this POA. If not, trows
   --  a BAD_PARAM exception
   --  Case USER_ID:
   --  Does nothing


--      (Self            : Id_Assignement_Policy_Ptr;
--       Other_Policies  : Policy_List_Ptr;
--       Map             : CORBA.Object_Map.Object_Map;
--       P_Servant       : Servant)
--      return Object_Id is abstract;
--    --  Is P_Servant necessary?
--    --  Adds an object in the given object_map
--    --  Case USER_ID:
--    --  Raises a WrongPolicy exception
--    --  Case SYSTEM_ID:
--    --  Returns an Object_Id ; the servant will be registered in the poa
--  with this ID
--    --
--    --  Uses the lifespan policy to create the object id


private
   type IdAssignementPolicy is abstract new Policy with
      record
         Value : IdAssignementPolicyValue;
      end record;


end CORBA.Policy.Id_Assignement_Policy;
