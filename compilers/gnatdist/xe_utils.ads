------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                             X E _ U T I L S                              --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 1995-2015, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
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

--  This package provides several global variables, routines and
--  exceptions of general use.

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with GNAT.OS_Lib; use GNAT.OS_Lib;
pragma Elaborate_All (GNAT.OS_Lib);

with XE_Types; use XE_Types;

package XE_Utils is

   ----------------------
   -- Global Variables --
   ----------------------

   Root          : constant String := "dsa";
   Cfg_Suffix    : constant String := ".cfg";
   Obj_Suffix    : constant String := Get_Object_Suffix.all;
   Exe_Suffix    : constant String := Get_Executable_Suffix.all;
   ALI_Suffix    : constant String := ".ali";
   ADB_Suffix    : constant String := ".adb";
   ADS_Suffix    : constant String := ".ads";
   Curdir_Id     : File_Name_Type;
   Root_Id       : File_Name_Type;
   Cfg_Suffix_Id : File_Name_Type;
   Obj_Suffix_Id : File_Name_Type;
   Exe_Suffix_Id : File_Name_Type;
   ALI_Suffix_Id : File_Name_Type;
   ADB_Suffix_Id : File_Name_Type;
   ADS_Suffix_Id : File_Name_Type;
   Stub_Dir_Name : File_Name_Type;
   Part_Dir_Name : File_Name_Type;
   PWD_Id        : File_Name_Type;
   Stub_Dir      : Unbounded_String;
   A_Stub_Dir    : Unbounded_String;
   E_Current_Dir : Unbounded_String;
   I_Current_Dir : Unbounded_String;

   --  Monolithic application main subprogram (set by Set_Application_Names)

   Monolithic_App_Unit_Name : File_Name_Type;
   Monolithic_Src_Base_Name : File_Name_Type;
   Monolithic_Src_Name      : File_Name_Type;
   Monolithic_ALI_Name      : File_Name_Type;
   Monolithic_Obj_Name      : File_Name_Type;

   Monolithic_Obj_Dir       : File_Name_Type;
   Hidden_Stubs_Dir         : File_Name_Type;
   --  Object dir for the monolithic application, and temporary directory to
   --  hide stubbed units from gnatmake.

   --  Project file for the complete application (set by Set_Application_Names)

   Dist_App_Project      : Name_Id;
   Dist_App_Project_File : File_Name_Type;

   PCS_Project       : Name_Id;
   PCS_Project_File  : File_Name_Type;
   --  Project file for the PCS

   Part_Main_Base_Name : File_Name_Type;
   Part_Main_Spec_Name : File_Name_Type;
   Part_Main_Body_Name : File_Name_Type;
   Part_Main_ALI_Name  : File_Name_Type;
   Part_Main_Obj_Name  : File_Name_Type;
   --  Partition main subprogram

   Part_Prj_File_Name : File_Name_Type;
   --  Partition project file

   Overridden_PCS_Units : File_Name_Type;
   --  Per-partition list of PCS units that are overridden by the partition

   procedure Initialize;
   --  Perform global initialization of this unit

   ------------------------------
   -- String and Name Handling --
   ------------------------------

   function Id (S : String) return Name_Id;
   --  Add S into name table and return id.

   function Quote (N : Name_Id) return Name_Id;
   --  Make a string containing N and return it as a Name_Id.

   function "&" (L : Name_Id; R : Name_Id) return Name_Id;
   function "&" (L : Name_Id; R : String) return Name_Id;

   function No (N : Name_Id) return Boolean;
   function Present (N : Name_Id) return Boolean;

   procedure Capitalize (S : in out String);
   function Capitalize (N : Name_Id) return Name_Id;
   function Capitalize (S : String) return String;
   --  Capitalize string or name id

   procedure To_Lower (S : in out String);
   procedure To_Lower (N : in out Name_Id);
   function  To_Lower (N : Name_Id) return Name_Id;

   function Name (N : Name_Id) return Name_Id;
   --  Remove any encoded info from unit name (%s or %b)

   procedure Set_Corresponding_Project_File_Name (N : out File_Name_Type);
   --  Assuming the Name_Buffer contains a project name, set N to the name of
   --  the corrsponding project file. Assumes that the project name is already
   --  all lowercase.

   ------------------------------------
   -- Command Line Argument Handling --
   ------------------------------------

   procedure Scan_Dist_Arg (Argv : String; Implicit : Boolean := True);
   --  Process one command line argument.
   --  Implicit is set True for additional flags generated internally by
   --  gnatdist.

   procedure Scan_Dist_Args (Args : String);
   --  Split Args into a list of arguments according to usual shell splitting
   --  semantics, and process each argument using Scan_Dist_Arg as implicit
   --  arguments.

   function More_Source_Files return Boolean;
   function Next_Main_Source return Name_Id;
   function Number_Of_Files return Natural;

   procedure Show_Dist_Args;
   --  Output processed command line switches (for debugging purposes)

   procedure Set_Application_Names (Configuration_Name : Name_Id);
   --  Set the name of the monolithic application main subprogram and of the
   --  distributed application project based on the configuration name.
   --  Called once the configuration has been parsed.

   --------------------
   -- Error Handling --
   --------------------

   Fatal_Error         : exception;   --  Operating system error
   Scanning_Error      : exception;   --  Error during scanning
   Parsing_Error       : exception;   --  Error during parsing
   Matching_Error      : exception;   --  Error on overloading
   Partitioning_Error  : exception;   --  Error during partitionning
   Compilation_Error   : exception;   --  Error during compilation
   Usage_Error         : exception;   --  Command line error
   Not_Yet_Implemented : exception;

   --  Note: Compilation_Error may be raised only when a previous build command
   --  has already emitted an error message. Gnatdist itself will silently
   --  exist (with an error status) in that case, and won't produce any
   --  further error message.

   type Exit_Code_Type is
     (E_Success,    -- No warnings or errors
      E_Fatal);     -- Fatal (serious) error

   procedure Exit_Program (Code : Exit_Code_Type);
   --  Clean up temporary files and exit with appropriate return code

   procedure Write_Missing_File (Fname : File_Name_Type);
   --  Output an informational message to indicate that Fname is missing

   procedure Write_Warnings_Pragmas;
   --  Generate pragmas to turn off warnings and style checks

   -----------------------
   --  Command Handling --
   -----------------------

   function "+" (S : String) return Unbounded_String
     renames To_Unbounded_String;

   package Unbounded_String_Vectors is
     new Ada.Containers.Vectors
           (Index_Type   => Positive,
            Element_Type => Ada.Strings.Unbounded.Unbounded_String);
   subtype Argument_Vec is Unbounded_String_Vectors.Vector;
   No_Args : Argument_Vec renames Unbounded_String_Vectors.Empty_Vector;

   procedure Push (AV : in out Argument_Vec; U : Unbounded_String);
   procedure Push (AV : in out Argument_Vec; S : String);
   procedure Push (AV : in out Argument_Vec; N : Name_Id);
   --  Append the given argument to AV.
   --  Note: the Name_Id variant clobbers Name_Buffer and Name_Len.

   type File_Name_List is array (Natural range <>) of File_Name_Type;

   procedure Execute
     (Command   : String;
      Arguments : Argument_Vec;
      Success   : out Boolean);

   procedure Build
     (Library    : File_Name_Type;
      Arguments  : Argument_Vec;
      Fatal      : Boolean := True;
      Progress   : Boolean := False);
   --  Execute gnat make and add gnatdist link flags

   procedure Compile
     (Source    : File_Name_Type;
      Arguments : Argument_Vec;
      Fatal     : Boolean := True);
   --  Execute gnat compile and add gnatdist gcc flags

   procedure List
     (Sources   : File_Name_List;
      Arguments : Argument_Vec;
      Output    : out File_Name_Type;
      Fatal     : Boolean := True);
   --  List source info into Output and raise Fatal Error if not
   --  successful. The user has to close Output afterwards.

end XE_Utils;
