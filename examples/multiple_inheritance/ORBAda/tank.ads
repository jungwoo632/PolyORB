-- ==================================================== --
-- ===  Code automatically generated by IDL to Ada  === --
-- ===  compiler OrbAda-idl2ada                     === --
-- ===  Copyright Top Graph'X  1997                 === --
-- ==================================================== --
with Corba.Object ;
with Vehicle ;
with Weapon ;
package tank is

   type Ref is new Vehicle.Ref with null record;

   function To_tank (Self : Corba.Object.Ref'class) return Ref'class;

   function To_Weapon (Self : in Ref) return Weapon.Ref'class;

   procedure shoot
      ( Self : in Ref) ;

   function To_Ref (From : in Corba.Any) return Ref;
   function To_Any (From : in Ref) return Corba.Any;

   Null_Ref : constant Ref := (Vehicle.Null_Ref with null record);

   Tgx_Service_Name : Corba.ObjectId := Corba.To_Unbounded_String
      ("tank") ;

   tank_R_Id : constant Corba.RepositoryId :=
      Corba.To_Unbounded_String ("IDL:tank:1.0") ;
end tank;


