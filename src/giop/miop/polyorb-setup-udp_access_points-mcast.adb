------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                  POLYORB.SETUP.UDP_ACCESS_POINTS.MCAST                   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2003 Free Software Foundation, Inc.             --
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

--  Setup socket for multicast

with PolyORB.Components;
with PolyORB.Sockets;
with PolyORB.Transport.Datagram.Sockets_In;

package body PolyORB.Setup.UDP_Access_Points.MCast is

   procedure Initialize_MCast
     (API     : in out UDP_Access_Point_Info;
      Address : in     Inet_Addr_Type;
      Port    : in     Port_Type)
   is
      use PolyORB.Sockets;
      use PolyORB.Transport.Datagram.Sockets_In;

   begin
      Initialize_Socket (API);

      API.Address :=
        Sock_Addr_Type'(Addr => Address,
                        Port => Port,
                        Family => Family_Inet);

      Set_Socket_Option
        (API.Socket,
         IP_Protocol_For_IP_Level,
         (Add_Membership, Address, Any_Inet_Addr));
      --  Register to multicast group

      Set_Socket_Option
        (API.Socket,
         IP_Protocol_For_IP_Level,
         (Multicast_Loop, True));
      --  Allow local multicast operation

      Init_Socket_In
        (Socket_In_Access_Point (API.SAP.all), API.Socket, API.Address, False);

      if API.PF /= null then
         Create_Factory
           (API.PF.all,
            API.SAP,
            PolyORB.Components.Component_Access (The_ORB));
      end if;
   end Initialize_MCast;

end PolyORB.Setup.UDP_Access_Points.MCast;
