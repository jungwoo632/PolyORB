------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--    P O L Y O R B . M O M A _ P . P R O V I D E R . W A R E H O U S E     --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2003 Free Software Foundation, Inc.           --
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

--  A dynamic, protected  dictionary of Any, indexed by Strings. It is used
--  as a placeholder for received messages.

with PolyORB.Any;
with PolyORB.Tasking.Rw_Locks;
with PolyORB.Utils.HFunctions.Hyper;
with PolyORB.Utils.HTables.Perfect;

with MOMA.Types;

package PolyORB.MOMA_P.Provider.Warehouse is

   Key_Not_Found : exception;

   type Warehouse is private;

   procedure Register
     (W : in out Warehouse;
      K :        String;
      V :        PolyORB.Any.Any);
   --  Associate key K with value V.

   procedure Unregister
     (W : in out Warehouse;
      K :        String);
   --  Remove any association for K. Key_Not_Found is raised
   --  if no value was registered for this key.

   function Lookup
      (W : Warehouse;
       K : String)
     return PolyORB.Any.Any;
   --  Lookup K in the dictionary, and return the associated value.
   --  Key_Not_Found is raised if no value was registered for this
   --  key.

   function Lookup
     (W       : Warehouse;
      K       : String;
      Default : PolyORB.Any.Any)
     return PolyORB.Any.Any;
   --  As above, but Default is returned for non-registered keys,
   --  instead of raising an exception.

   procedure Set_Persistence
     (W           : in out Warehouse;
      Persistence :        MOMA.Types.Persistence_Mode);
   --  Set persistency flag for this warehouse,
   --  Note : this overrides any flag set for a message if set to a mode
   --  allowing persistence.

   --  XXX Warning : not safe in case of multiple message pools !!!!

private

   package Perfect_Htable is
      new PolyORB.Utils.HTables.Perfect
     (PolyORB.Any.Any,
      PolyORB.Utils.HFunctions.Hyper.Hash_Hyper_Parameters,
      PolyORB.Utils.HFunctions.Hyper.Default_Hash_Parameters,
      PolyORB.Utils.HFunctions.Hyper.Hash,
      PolyORB.Utils.HFunctions.Hyper.Next_Hash_Parameters);
   use Perfect_Htable;

   type Warehouse is record
      T             : Table_Instance;
      T_Initialized : Boolean := False;
      T_Persistence : MOMA.Types.Persistence_Mode := MOMA.Types.None;
      T_Lock        : PolyORB.Tasking.Rw_Locks.Rw_Lock_Access;
   end record;

end PolyORB.MOMA_P.Provider.Warehouse;
