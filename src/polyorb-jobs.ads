------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                         P O L Y O R B . J O B S                          --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2004 Free Software Foundation, Inc.           --
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

--  Job management for ORB activities.

--  $Id$

with PolyORB.Utils.Chained_Lists;

package PolyORB.Jobs is

   pragma Preelaborate;

   ---------
   -- Job --
   ---------

   type Job is abstract tagged limited private;

   type Job_Access is access all Job'Class;
   --  A Job is any elementary activity that may
   --  be assigned to an ORB task to be entirely
   --  processed within one ORB loop iteration.

   procedure Run (J : access Job) is abstract;
   --  Execute the given Job. A task processes a Job
   --  by invoking its Run primitive.

   procedure Free (X : in out Job_Access);
   --  Deallocate X.all.

   ---------------
   -- Job_Queue --
   ---------------

   type Job_Selector is access
     function (J : access Job'Class) return Boolean;
   --  A predicate on jobs, used by clients of Job_Queue
   --  to select a job that matches some criterion.

   Any_Job : constant Job_Selector;
   --  A job selector that is always true.

   type Job_Queue is limited private;

   type Job_Queue_Access is access all Job_Queue;
   --  A queue of pending jobs.

   function Create_Queue return Job_Queue_Access;
   --  Create a new job queue.

   procedure Queue_Job
     (Q : access Job_Queue;
      J :        Job_Access);
   --  Enter a pending Job into Q.

   function Is_Empty (Q : access Job_Queue) return Boolean;
   --  True if, and only if, Q contains no pending Job.

   function Fetch_Job
     (Q        : access Job_Queue;
      Selector :        Job_Selector := Any_Job)
      return Job_Access;
   --  Returns a pending Job that matches Selector (i.e.
   --  such that Selector.all (Job) is true), and remove
   --  it from Q. Null is returned if no matching job exists.

   --  The caller must ensure that all primitive operations
   --  of Job_Queue are called only from within a critical
   --  section.

   function Length (Q : access Job_Queue) return Natural;

private

   pragma Inline (Fetch_Job);

   type Job is abstract tagged limited null record;

   package Job_Queues is new PolyORB.Utils.Chained_Lists
     (Job_Access, Doubly_Chained => True);

   subtype Job_Queue_Internal is Job_Queues.List;

   type Job_Queue is limited record
     Contents : Job_Queue_Internal;
   end record;

   Any_Job : constant Job_Selector := null;

end PolyORB.Jobs;
