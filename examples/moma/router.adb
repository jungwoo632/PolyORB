------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                               R O U T E R                                --
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

--  Testing MOMA router.
--  XXX Not implemented yet !!!

--  $Id$

with Ada.Command_Line;
with Ada.Text_IO;

with PolyORB.Minimal_Servant.Tools;
with PolyORB.References;
with PolyORB.References.IOR;
with PolyORB.Types;

with PolyORB.Setup.No_Tasking_Server;
pragma Elaborate_All (PolyORB.Setup.No_Tasking_Server);
pragma Warnings (Off, PolyORB.Setup.No_Tasking_Server);

with MOMA.Configuration.Server;
with MOMA.Types;

procedure Router is

   use Ada.Command_Line;
   use Ada.Text_IO;

   use PolyORB.Minimal_Servant.Tools;

   use MOMA.Configuration;
   use MOMA.Configuration.Server;
   use MOMA.Types;

   MOMA_Ref : PolyORB.References.Ref;
   Pool_1   : Message_Pool;
   Router_1 : PolyORB.References.Ref;

begin

   --  Argument check.
   if Argument_Count >= 1 then
      Put_Line ("usage : router");
      return;
   end if;

   --  Load Configuration File.
   Load_Configuration_File ("destinations.conf");

   --  Get information about destination #1.
   Pool_1 := MOMA.Configuration.Get_Message_Pool (1);

   --  Create one message pool and output its reference.
   MOMA.Configuration.Server.Create_Message_Pool (Pool_1, MOMA_Ref);
   Put_Line ("Pool IOR :");
   Put_Line (PolyORB.Types.To_Standard_String
             (PolyORB.References.IOR.Object_To_String (MOMA_Ref)));

   --  Create one router and output its reference.
   MOMA.Configuration.Server.Create_Router (Router_1);
   Put_Line ("Router IOR :");
   Put_Line (PolyORB.Types.To_Standard_String
             (PolyORB.References.IOR.Object_To_String (Router_1)));

   --  Run the server.
   Run_Server;

end Router;
