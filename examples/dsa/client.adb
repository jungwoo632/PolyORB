with Ada.Text_IO; use Ada.Text_IO;
with RCI;
with RT;
with SP;

with PolyORB.Initialization;
with System.RPC;

pragma Warnings (Off);
with PolyORB.ORB.No_Tasking;
with PolyORB.ORB;
with PolyORB.Setup;
with PolyORB.Setup.Client;
with PolyORB.DSA_P.Partitions;
pragma Warnings (On);

procedure Client is
   S : constant String := "Hello DSA world!";
   RAS : RCI.echo_RAS;

   procedure Try_RACW (Name : String);
   procedure Try_RACW (Name : String) is
      use type RT.RACW;
      Obj : RT.RACW;
   begin
      Put_Line ("Trying RACW with Name = """ & Name & """");
      Obj := RCI.Get_Obj (Name);
      if Obj = null then
         Put_Line ("Got null!");
      else
         Put_Line ("Got not null: " & RT.Tekitoa (Obj.all) & " is alive!");
      end if;
   end Try_RACW;

   Z : constant RCI.Complex := (Re => 2.0, Im => 3.0);
   This_Partition_ID : System.RPC.Partition_ID;

begin
   --  XXX BEGIN PolyORB INITIAL SETUP
   PolyORB.Initialization.Initialize_World;
   This_Partition_ID := System.RPC.Partition_ID
     (PolyORB.DSA_P.Partitions.Allocate_Partition_ID ("clientp"));
   --  XXX END PolyORB INITIAL SETUP

   SP.Shared_Integer := 42;
   Put_Line ("I said: " & S);
   Put_Line ("The server replied: "
     & RCI.echoString (S));
   RAS := RCI.echoString'Access;
   Put_Line ("through RAS: " & RAS (S & " (RASI)"));
   Put_Line ("through RAS: " & RAS.all (S & " (RASE)"));

   Try_RACW ("");
   Try_RACW ("Elvis");

   Put_Line ("|2 + 3i|^2 = " & Float'Image (RCI.Modulus2 (Z)));
end Client;
