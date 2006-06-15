------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--           P O L Y O R B . B I N D I N G _ O B J E C T _ Q O S            --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--           Copyright (C) 2006, Free Software Foundation, Inc.             --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 51 Franklin Street, Fifth    --
-- Floor, Boston, MA 02111-1301, USA.                                       --
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

with PolyORB.Binding_Objects;
with PolyORB.QoS;

package PolyORB.Binding_Object_QoS is

   procedure Set_Binding_Object_QoS
     (BO  : access PolyORB.Binding_Objects.Binding_Object'Class;
      QoS :        PolyORB.QoS.QoS_Parameters);

   function Get_Binding_Object_QoS
     (BO  : access PolyORB.Binding_Objects.Binding_Object'Class)
      return PolyORB.QoS.QoS_Parameters;

   procedure Set_Binding_Object_QoS
     (BO   : access PolyORB.Binding_Objects.Binding_Object'Class;
      Kind :        PolyORB.QoS.QoS_Kind;
      QoS  :        PolyORB.QoS.QoS_Parameter_Access);

   function Is_Compatible
     (BO  : access PolyORB.Binding_Objects.Binding_Object'Class;
      QoS : PolyORB.QoS.QoS_Parameters) return Boolean;

   type QoS_Compatibility_Check_Proc is
     access function
     (BO_QoS : PolyORB.QoS.QoS_Parameter_Access;
      QoS    : PolyORB.QoS.QoS_Parameter_Access) return Boolean;

   procedure Register
     (Kind : PolyORB.QoS.QoS_Kind;
      Proc : QoS_Compatibility_Check_Proc);

end PolyORB.Binding_Object_QoS;
