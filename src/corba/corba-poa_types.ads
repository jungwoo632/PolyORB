with Droopi.Obj_Adapters;
with Droopi.Objects;         use Droopi.Objects;
with Sequences.Unbounded;
with Unchecked_Deallocation;

---------------------
-- CORBA.POA_Types --
---------------------

package CORBA.POA_Types is

   type Obj_Adapter is abstract new Droopi.Obj_Adapters.Obj_Adapter
     with null record;
   type Obj_Adapter_Access is access all Obj_Adapter'Class;

   package POA_Sequences is new Sequences.Unbounded (Obj_Adapter_Access);
   subtype POAList is POA_Sequences.Sequence;
   type POAList_Access is access all POAList;

   type Object_Id is new Droopi.Objects.Object_Id;
   type Object_Id_Access is access all Object_Id;

   type Servant is abstract new Droopi.Objects.Servant with null record;
   type Servant_Access is access all Servant'Class;

   type Unmarshalled_Oid is
     record
         Id               : CORBA.String;
         System_Generated : CORBA.Boolean;
         Persistency_Flag : CORBA.Long;
         --  ??? How do we implement the PERSISTENT policy?
     end record;
   type Unmarshalled_Oid_Access is access Unmarshalled_Oid;
   --  The unmarshalled Object_Id

   function Create_Id
     (Name             : in CORBA.String;
      System_Generated : in CORBA.Boolean;
      Persistency_Flag : in CORBA.Long)
     return Unmarshalled_Oid_Access;
   --  Create an Unmarshalled_Oid

   function Create_Id
     (Name             : in CORBA.String;
      System_Generated : in CORBA.Boolean;
      Persistency_Flag : in CORBA.Long)
     return Object_Id_Access;
   --  Create an Unmarshalled_Oid, and then marshall it into an Object_Id

   function Unmarshall (Oid : Object_Id_Access) return Unmarshalled_Oid_Access;
   --  Unmarshall an Object_Id into a Unmarshalled_Oid

   function Marshall (U_Oid : Unmarshalled_Oid_Access) return Object_Id_Access;
   --  Marshall an Unmarshalled_Oid into an Object_Id

   procedure Deallocate is new Ada.Unchecked_Deallocation
     (Unmarshalled_Oid, Unmarshalled_Oid_Access);

end CORBA.POA_Types;
