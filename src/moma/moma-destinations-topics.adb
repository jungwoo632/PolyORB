------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--             M O M A . D E S T I N A T I O N S . T O P I C S              --
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

--  $Id$

package body MOMA.Destinations.Topics is

   ------------
   -- Delete --
   ------------

   procedure Delete is
   begin
      null;
   end Delete;

   --------------
   -- Get_Name --
   --------------

   function Get_Name (Self : Topic) return PolyORB.Types.String is
   begin
      return Self.Name;
   end Get_Name;

   --------------
   -- Set_Name --
   --------------

   procedure Set_Name (Self : in out Topic;
                       Name : PolyORB.Types.String) is
   begin
      Self.Name := Name;
   end Set_Name;

   -------------
   -- Get_Ref --
   -------------

   function Get_Ref (Self : Topic) return PolyORB.References.Ref is
   begin
      return Self.Ref;
   end Get_Ref;

   -------------
   -- Set_Ref --
   -------------

   procedure Set_Ref (Self : in out Topic;
                      Ref  : PolyORB.References.Ref) is
   begin
      Self.Ref := Ref;
   end Set_Ref;

end MOMA.Destinations.Topics;

