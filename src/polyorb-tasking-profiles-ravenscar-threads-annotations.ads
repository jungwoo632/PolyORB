------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--         POLYORB.TASKING.PROFILES.RAVENSCAR.THREADS.ANNOTATIONS           --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2004-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_2012;

with PolyORB.Annotations;
with PolyORB.Initialization;
with PolyORB.Tasking.Threads.Annotations;

generic
package PolyORB.Tasking.Profiles.Ravenscar.Threads.Annotations is

   type Ravenscar_TAF is
     new PolyORB.Tasking.Threads.Annotations.Thread_Annotations_Factory
     with private;

   type Ravenscar_TAF_Access is access all Ravenscar_TAF;

   overriding function Get_Current_Thread_Notepad
     (TAF : access Ravenscar_TAF)
     return PolyORB.Annotations.Notepad_Access;

private
   type Ravenscar_TAF is
     new PolyORB.Tasking.Threads.Annotations.Thread_Annotations_Factory
     with null record;

   procedure Initialize;

   Initializer : constant PolyORB.Initialization.Initializer :=
                   Initialize'Access;

end PolyORB.Tasking.Profiles.Ravenscar.Threads.Annotations;
