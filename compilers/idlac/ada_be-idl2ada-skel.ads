------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                  A D A _ B E . I D L 2 A D A . S K E L                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2003 Free Software Foundation, Inc.           --
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
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Idl_Fe.Types;          use Idl_Fe.Types;
with Ada_Be.Source_Streams; use Ada_Be.Source_Streams;

private package Ada_Be.Idl2Ada.Skel is

   --  This package contains the code common to the skeleton and the
   --  delegate packages.

   function Suffix (Is_Delegate : in Boolean) return String;

   procedure Gen_Node_Spec
     (CU          : in out Compilation_Unit;
      Node        : in     Node_Id;
      Is_Delegate : in     Boolean);

   procedure Gen_Node_Body
     (CU          : in out Compilation_Unit;
      Node        : in     Node_Id;
      Is_Delegate : in     Boolean);

   procedure Gen_Body_Common_End
     (CU          : in out Compilation_Unit;
      Node        : in     Node_Id;
      Is_Delegate : in     Boolean);
   --  generates code for skel_body that is common
   --  for interfaces and valuetypes supporting interfaces
   --  at the end of the package.

end Ada_Be.Idl2Ada.Skel;
