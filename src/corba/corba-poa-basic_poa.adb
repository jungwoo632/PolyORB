with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time;

with Sequences.Unbounded;
with Sequences.Unbounded.Search;
with Droopi.Log;
pragma Elaborate_All (Droopi.Log);

with Droopi.CORBA_P.Exceptions; use Droopi.CORBA_P.Exceptions;
with CORBA.Policy_Types;
with CORBA.Policy_Values;


package body CORBA.POA.Basic_POA is

   use POA_Types;
   use Droopi.Log;
   use Droopi.Locks;
   use CORBA.POA_Manager;
   use CORBA.Policy;
   use CORBA.Policy_Types;

   use CORBA.Policy.Thread_Policy;

   package L is new Droopi.Log.Facility_Log ("CORBA.POA.Root_POA");
   procedure O (Message : in Standard.String; Level : Log_Level := Debug)
     renames L.Output;

   function Get_Boot_Time return Time_Stamp;

   function Get_Child (Adapter : access Basic_Obj_Adapter;
                       Name    : in     String)
                      return POA_Types.Obj_Adapter_Access;
   --  Look in the list of children of the Adapter if an OA with
   --  the given name already exists.
   --  The function doesn't take care of the Lock on the children!

   procedure Init_With_User_Policies (OA       : Basic_Obj_Adapter_Access;
                                      Policies : Policy.PolicyList_Access);
   procedure Init_With_Default_Policies (OA : Basic_Obj_Adapter_Access);
   procedure Check_Policies_Compatibility (OA : Basic_Obj_Adapter_Access);
   procedure Register_Child (Self  : access Basic_Obj_Adapter;
                             Child :        Basic_Obj_Adapter_Access);

   ---------------
   -- Get_Child --
   ---------------

   function Get_Child (Adapter : access Basic_Obj_Adapter;
                       Name    : in     String)
                      return POA_Types.Obj_Adapter_Access
   is
      use POA_Sequences;
      Result  : POAList;
      A_Child : POA_Types.Obj_Adapter_Access;
   begin
      if Adapter.Children /= null then
         for I in 1 .. Length (Adapter.Children.all) loop
            A_Child := Element_Of (Adapter.Children.all, I);
            if CORBA.POA.Obj_Adapter_Access (A_Child).Name = Name then
               Unlock_R (Adapter.Children_Lock);
               return A_Child;
            end if;
         end loop;
      end if;
      return null;
   end Get_Child;

   -------------------
   -- Get_Boot_Time --
   -------------------

   function Get_Boot_Time
     return Time_Stamp
   is
      use Ada.Real_Time;
      T  : Time;
      SC : Seconds_Count;
      TS : Time_Span;
   begin
      T := Clock;
      Split (T, SC, TS);

      return Time_Stamp (Unsigned_Long (SC));
   end Get_Boot_Time;

   -----------------------------
   -- Init_With_User_Policies --
   -----------------------------

   procedure Init_With_User_Policies (OA       : Basic_Obj_Adapter_Access;
                                      Policies : Policy.PolicyList_Access)
   is
      A_Policy : Policy_Access;
   begin
      for I in 1 .. Policy_Sequences.Length (Policies.all) loop
         A_Policy := Policy_Sequences.Element_Of (Policies.all, I);
         case A_Policy.Policy_Type is
            when THREAD_POLICY_ID =>
               if OA.Thread_Policy /= null then
                  O ("Duplicate in ThreadPolicy: using last one");
               end if;
               OA.Thread_Policy
                 := Create (ThreadPolicy (A_Policy.all));

            when LIFESPAN_POLICY_ID =>
               if OA.Lifespan_Policy /= null then
                  O ("Duplicate in LifespanPolicy: using last one");
               end if;
               OA.Lifespan_Policy
                 := Create (LifespanPolicy (A_Policy.all));

            when ID_UNIQUENESS_POLICY_ID =>
               if OA.Id_Uniqueness_Policy /= null then
                  O ("Duplicate in IdUniquenessPolicy: using last one");
               end if;
               OA.Id_Uniqueness_Policy
                 := Create (IdUniquenessPolicy (A_Policy.all));

            when ID_ASSIGNEMENT_POLICY_ID =>
               if OA.Id_Assignement_Policy /= null then
                  O ("Duplicate in IdAssignementPolicy: using last one");
               end if;
               OA.Id_Assignement_Policy
                 := Create (IdAssignementPolicy (A_Policy.all));

            when SERVANT_RETENTION_POLICY_ID =>
               if OA.Servant_Retention_Policy /= null then
                  O ("Duplicate in ServantRetentionPolicy: using last one");
               end if;
               OA.Servant_Retention_Policy
                 := Create (ServantRetentionPolicy (A_Policy.all));

            when REQUEST_PROCESSING_POLICY_ID =>
               if OA.Request_Processing_Policy /= null then
                  O ("Duplicate in RequestProcessingPolicy: using last one");
               end if;
               OA.Request_Processing_Policy
                 := Create (RequestProcessingPolicy (A_Policy.all));

            when IMPLICIT_ACTIVATION_POLICY_ID =>
               if OA.Implicit_Activation_Policy /= null then
                  O ("Duplicate in ImplicitActivationPolicy: using last one");
               end if;
               OA.Implicit_Activation_Policy
                 := Create (ImplicitActivationPolicy (A_Policy.all));

            when others =>
               null;
               O ("Unknown policy ignored");
         end case;
      end loop;
   end Init_With_User_Policies;

   --------------------------------
   -- Init_With_Default_Policies --
   --------------------------------

   procedure Init_With_Default_Policies (OA : Basic_Obj_Adapter_Access)
   is
      use CORBA.Policy_Values;
   begin
      if OA.Thread_Policy = null then
         OA.Thread_Policy := Create_Thread_Policy (ORB_CTRL_MODEL);
      end if;

      if OA.Lifespan_Policy = null then
         OA.Lifespan_Policy
           := Create_Lifespan_Policy (Policy_Values.TRANSIENT);
      end if;

      if OA.Id_Uniqueness_Policy = null then
         OA.Id_Uniqueness_Policy :=
           Create_Id_Uniqueness_Policy (UNIQUE_ID);
      end if;

      if OA.Id_Assignement_Policy = null then
         OA.Id_Assignement_Policy :=
           Create_Id_Assignement_Policy (SYSTEM_ID);
      end if;

      if OA.Servant_Retention_Policy = null then
         OA.Servant_Retention_Policy :=
           Create_Servant_Retention_Policy (RETAIN);
      end if;

      if OA.Request_Processing_Policy = null then
         OA.Request_Processing_Policy :=
           Create_Request_Processing_Policy (USE_ACTIVE_OBJECT_MAP_ONLY);
      end if;

      if OA.Implicit_Activation_Policy = null then
         OA.Implicit_Activation_Policy :=
           Create_Implicit_Activation_Policy (NO_IMPLICIT_ACTIVATION);
      end if;
   end Init_With_Default_Policies;

   ----------------------------------
   -- Check_Policies_Compatibility --
   ----------------------------------

   procedure Check_Policies_Compatibility (OA : Basic_Obj_Adapter_Access)
   is
   begin
      Check_Compatibility
        (OA.Thread_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Lifespan_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Id_Uniqueness_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Id_Assignement_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Servant_Retention_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Request_Processing_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
      Check_Compatibility
        (OA.Implicit_Activation_Policy.all,
         CORBA.POA_Types.Obj_Adapter_Access (OA));
   end Check_Policies_Compatibility;

   --------------------
   -- Register_Child --
   --------------------

   procedure Register_Child (Self  : access Basic_Obj_Adapter;
                             Child :        Basic_Obj_Adapter_Access)
   is
      use CORBA.POA_Types.POA_Sequences;
   begin
      Lock_W (Self.Children_Lock);
      if (Self.Children = null) then
         Self.Children := new POAList;
         Append (Sequence (Self.Children.all),
                 CORBA.POA_Types.Obj_Adapter_Access (Child));
      end if;
      Unlock_W (Self.Children_Lock);
   end Register_Child;

   ----------------
   -- Create_POA --
   ----------------

   function Create_POA
     (Self         : access Basic_Obj_Adapter;
      Adapter_Name :        String;
      A_POAManager :        POA_Manager.POAManager_Access;
      Policies     :        Policy.PolicyList_Access)
     return Obj_Adapter_Access
   is
      New_Obj_Adapter : Basic_Obj_Adapter_Access;
      Children_Locked : Boolean := False;
   begin
      O ("Enter Basic_POA.Create_POA");
      --  ??? Add check code here

      --  If self is null, that means that the poa to create is the RootPOA

      --  Look if there is already a child with this name

      if Self.Children /= null then
         Lock_W (Self.Children_Lock);
         --  Write Lock here: content of children has to be the same when
         --  we add the new child.
         Children_Locked := True;
         if Get_Child (Self, Adapter_Name) /= null then
            Droopi.CORBA_P.Exceptions.Raise_Adapter_Already_Exists;
         end if;
      end if;

      --  Create new object adapter
      New_Obj_Adapter           := new Basic_Obj_Adapter;
      Create (New_Obj_Adapter.Children_Lock);
      Create (New_Obj_Adapter.Map_Lock);
      New_Obj_Adapter.Boot_Time := Get_Boot_Time;
      New_Obj_Adapter.Father := POA_Types.Obj_Adapter_Access (Self);
      New_Obj_Adapter.Name   := Adapter_Name;

      if A_POAManager = null then
         --  ??? Use POAManager factory
         null;
      else
         New_Obj_Adapter.POA_Manager := A_POAManager;
      end if;

      --  Init policies with those given by the user
      if Policies /= null then
         Init_With_User_Policies (New_Obj_Adapter, Policies);
      end if;

      --  Use default policies if not provided by the user
      Init_With_Default_Policies (New_Obj_Adapter);

      --  Check compatibilities between policies
      Check_Policies_Compatibility (New_Obj_Adapter);

      --  ??? If error, clean memory
      --  --> An exception is raised: catch it, free the memoy, raise exception

      --  Register new obj_adapter as a sibling of the current POA
      if not Children_Locked then
         Lock_W (Self.Children_Lock);
      end if;
      Register_Child (Self, New_Obj_Adapter);
      Unlock_W (Self.Children_Lock);

      return Obj_Adapter_Access (New_Obj_Adapter);

   exception
      when CORBA.Adapter_Already_Exists =>
         --  Reraise exception
         Droopi.CORBA_P.Exceptions.Raise_Adapter_Already_Exists;
         Unlock_W (Self.Children_Lock);
         return null;
      when CORBA.Invalid_Policy =>
         --  ??? Free POA Manager, if a new one has been created
         Unlock_W (Self.Children_Lock);
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Thread_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Id_Uniqueness_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Id_Assignement_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Implicit_Activation_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Lifespan_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Request_Processing_Policy));
         Free (New_Obj_Adapter.Thread_Policy.all,
               Policy_Access (New_Obj_Adapter.Servant_Retention_Policy));
         Droopi.CORBA_P.Exceptions.Raise_Invalid_Policy;
         return null;
   end Create_POA;

   ---------------------
   -- Create_Root_POA --
   ---------------------

   function Create_Root_POA
     return Obj_Adapter_Access
   is
      New_Obj_Adapter : Basic_Obj_Adapter_Access;
   begin
      O ("Enter Basic_POA.Create_Root_POA");

      --  Create new object adapter
      New_Obj_Adapter           := new Basic_Obj_Adapter;
      Create (New_Obj_Adapter.Children_Lock);
      Create (New_Obj_Adapter.Map_Lock);
      New_Obj_Adapter.Boot_Time := Get_Boot_Time;
      New_Obj_Adapter.Name   := To_CORBA_String ("RootPOA");

      --  ??? Use POAManager factory

      --  Use default policies
      Init_With_Default_Policies (New_Obj_Adapter);

      return Obj_Adapter_Access (New_Obj_Adapter);
   end Create_Root_POA;

   ------------
   -- Create --
   ------------

   procedure Create (OA : out Basic_Obj_Adapter)
   is
   begin
      null;
   end Create;

   --------------------------
   -- Create_Thread_Policy --
   --------------------------

   function Create_Thread_Policy (Value : ThreadPolicyValue)
                                 return ThreadPolicy_Access
   is
      use CORBA.Policy.Thread_Policy;
   begin
      return Create (Value);
   end Create_Thread_Policy;

   ----------------------------
   -- Create_Lifespan_Policy --
   ----------------------------

   function Create_Lifespan_Policy (Value : LifespanPolicyValue)
                                 return LifespanPolicy_Access
   is
      use CORBA.Policy.Lifespan_Policy;
   begin
      return Create (Value);
   end Create_Lifespan_Policy;

   ---------------------------------
   -- Create_Id_Uniqueness_Policy --
   ---------------------------------

   function Create_Id_Uniqueness_Policy
     (Value : IdUniquenessPolicyValue)
     return IdUniquenessPolicy_Access
   is
      use CORBA.Policy.Id_Uniqueness_Policy;
   begin
      return Create (Value);
   end Create_Id_Uniqueness_Policy;

   ----------------------------------
   -- Create_Id_Assignement_Policy --
   ----------------------------------

   function Create_Id_Assignement_Policy
     (Value : IdAssignementPolicyValue)
     return IdAssignementPolicy_Access
   is
      use CORBA.Policy.Id_Assignement_Policy;
   begin
      return Create (Value);
   end Create_Id_Assignement_Policy;

   -------------------------------------
   -- Create_Servent_Retention_Policy --
   -------------------------------------

   function Create_Servant_Retention_Policy
     (Value : ServantRetentionPolicyValue)
     return ServantRetentionPolicy_Access
   is
      use CORBA.Policy.Servant_Retention_Policy;
   begin
      return Create (Value);
   end Create_Servant_Retention_Policy;

   --------------------------------------
   -- Create_Request_Processing_Policy --
   --------------------------------------

   function Create_Request_Processing_Policy
     (Value : RequestProcessingPolicyValue)
     return RequestProcessingPolicy_Access
   is
      use CORBA.Policy.Request_Processing_Policy;
   begin
      return Create (Value);
   end Create_Request_Processing_Policy;

   ---------------------------------------
   -- Create_Implicit_Activation_Policy --
   ---------------------------------------

   function Create_Implicit_Activation_Policy
     (Value : ImplicitActivationPolicyValue)
     return ImplicitActivationPolicy_Access
   is
      use CORBA.Policy.Implicit_Activation_Policy;
   begin
      return Create (Value);
   end Create_Implicit_Activation_Policy;

   ---------------------
   -- Activate_Object --
   ---------------------

   function Activate_Object
     (Self      : access Basic_Obj_Adapter;
      P_Servant : in     Servant_Access)
     return Object_Id
   is
      Oid : Object_Id_Access
        := Activate_Object (Self.Servant_Retention_Policy.all,
                            POA_Types.Obj_Adapter_Access (Self),
                            P_Servant);
   begin
      return Oid.all;
   end Activate_Object;

   -----------------------------
   -- Activate_Object_With_Id --
   -----------------------------

   procedure Activate_Object_With_Id
     (Self      : access Basic_Obj_Adapter;
      P_Servant : in     Servant_Access;
      Oid       : in     Object_Id)
   is
   begin
      --      CORBA.Policy.Servant_Retention_Policy.Activate_Object_With_Id
      Activate_Object_With_Id (Self.Servant_Retention_Policy.all,
                               POA_Types.Obj_Adapter_Access (Self),
                               P_Servant,
                               Oid);
   end Activate_Object_With_Id;

   ----------------
   -- Deactivate --
   ----------------

   procedure Deactivate
     (Self      : access Basic_Obj_Adapter;
      Oid       : in Object_Id)
   is
   begin
      Deactivate (Self.Servant_Retention_Policy.all,
                  CORBA.POA_Types.Obj_Adapter_Access (Self),
                  Oid);
      --  ??? Wait for completion?
   end Deactivate;

   -------------------
   -- Servant_To_Id --
   -------------------

   function Servant_To_Id
     (Self      : access Basic_Obj_Adapter;
      P_Servant : in     Servant_Access)
     return Object_Id
   is
      Oid : Object_Id_Access
        := Servant_To_Id (Self.Request_Processing_Policy.all,
                          POA_Types.Obj_Adapter_Access (Self),
                          P_Servant);
   begin
      if Oid = null then
         Raise_Servant_Not_Active;
      end if;
      return Oid.all;
   end Servant_To_Id;

   -------------------
   -- Id_To_Servant --
   -------------------

   function Id_To_Servant
     (Self : access Basic_Obj_Adapter;
      Oid  :        Object_Id)
     return Servant_Access
   is
      Servant : Servant_Access;
   begin
      Servant := Id_To_Servant (Self.Request_Processing_Policy.all,
                                POA_Types.Obj_Adapter_Access (Self),
                                Oid);
      return Servant;
   end Id_To_Servant;

   ----------------------------------------------------
   --  Procedures and functions not yet implemented  --
   ----------------------------------------------------
   pragma Warnings (OFF);
   --  Avoid useless warnings

   -------------
   -- Destroy --
   -------------

   procedure Destroy (OA : in out Basic_Obj_Adapter)
   is
   begin
      null;
   end Destroy;

   ------------
   -- Export --
   ------------

   function Export
     (OA  : access Basic_Obj_Adapter;
      Obj :        Droopi.Objects.Servant_Access)
     return Droopi.Objects.Object_Id
   is
   begin
      return Export (OA, Obj);
   end Export;

   --------------
   -- Unexport --
   --------------

   procedure Unexport
     (OA : access Basic_Obj_Adapter;
      Id :        Droopi.Objects.Object_Id)
   is
   begin
      null;
   end Unexport;

   ------------------------
   -- Get_Empty_Arg_List --
   ------------------------

   function Get_Empty_Arg_List
     (OA     : Basic_Obj_Adapter;
      Oid    : Droopi.Objects.Object_Id;
      Method : Droopi.Requests.Operation_Id)
     return Droopi.Any.NVList.Ref
   is
   begin
      return Get_Empty_Arg_List (OA, Oid, Method);
   end Get_Empty_Arg_List;

   ----------------------
   -- Get_Empty_Result --
   ----------------------

   function Get_Empty_Result
     (OA     : Basic_Obj_Adapter;
      Oid    : Droopi.Objects.Object_Id;
      Method : Droopi.Requests.Operation_Id)
     return Droopi.Any.Any
   is
   begin
      return Get_Empty_Result (OA, Oid, Method);
   end Get_Empty_Result;

   ------------------
   -- Find_Servant --
   ------------------

   function Find_Servant
     (OA : access Basic_Obj_Adapter;
      Id :        Droopi.Objects.Object_Id)
     return Droopi.Objects.Servant_Access
   is
   begin
      return Find_Servant (OA, Id);
   end Find_Servant;

   ---------------------
   -- Release_Servant --
   ---------------------

   procedure Release_Servant
     (OA      : access Basic_Obj_Adapter;
      Id      :        Droopi.Objects.Object_Id;
      Servant : in out Droopi.Objects.Servant_Access)
   is
   begin
      null;
   end Release_Servant;

   pragma Warnings (ON);

end CORBA.POA.Basic_POA;
