with Ada.Text_Io;
with Tokens;

package body Errors is

   ----------------------------
   --  some usefull methods  --
   ----------------------------

   --  counters for errors and warnings
   Error_Count : Natural := 0;
   Warning_Count : Natural := 0;

   --  nice display of a natural
   function Nat_To_String (Val : Natural) return String is
      Res : String := Natural'Image (Val);
   begin
      return Res (2 .. Res'Last);
   end Nat_To_String;

   --  displays an error
   procedure Display_Error (Message : in String;
                            Level : in Error_Kind) is
      Loc : Location;
   begin
      Loc := Tokens.Get_Location;
      case Level is
         when Fatal =>
            Ada.Text_Io.Put ("FATAL ERROR occured at line ");
         when Error =>
            Ada.Text_Io.Put ("ERROR occured at line ");
         when WARNING =>
            Ada.Text_Io.Put ("WARNING occured at line ");
      end case;
      Ada.Text_Io.Put (Nat_To_String (Loc.Line));
      Ada.Text_Io.Put (", column ");
      Ada.Text_Io.Put (Nat_To_String (Loc.Col));
      Ada.Text_Io.Put (" of file ");
      Ada.Text_Io.Put (Loc.Filename);
      Ada.Text_Io.New_Line;
      Ada.Text_Io.Put ("    ");
      Ada.Text_Io.Put_Line (Message);
      Ada.Text_Io.New_Line;
   end Display_Error;


   --------------------------------------
   --  functions of the specification  --
   --------------------------------------

   --  deals with a lexer error
   --  displays the error and, depending of its level, raise it
   procedure Lexer_Error (Message : in String;
                          Level : in Error_Kind)is
   begin
      case Level is
         when Fatal =>
            null;
         when Error =>
            Error_Count := Error_Count + 1;
         when Warning =>
            Warning_Count := Warning_Count + 1;
      end case;
      Display_Error (Message, Level);
      if Level = Fatal then
         raise Fatal_Error;
      end if;
   end Lexer_Error;

   --  deals with a parser error
   --  displays the error and, depending of its level, raise it
   procedure Parser_Error (Message : in String;
                          Level : in Error_Kind)is
   begin
      case Level is
         when Fatal =>
            null;
         when Error =>
            Error_Count := Error_Count + 1;
         when Warning =>
            Warning_Count := Warning_Count + 1;
      end case;
      Display_Error (Message, Level);
      if Level = Fatal then
         raise Fatal_Error;
      end if;
   end Parser_Error;

      --  was there any errors ?
   function Is_Error return Boolean is
   begin
      return Error_Count > 0;
   end Is_Error;

   --  was there any warnings ?
   function Is_Warning return Boolean is
   begin
      return Warning_Count > 0;
   end Is_Warning;

   --  returns the number of warnings
   function Warning_Number return Natural is
   begin
      return Error_Count;
   end Warning_Number;

   --  returns the number of errors
   function Error_Number return Natural is
   begin
      return Warning_Count;
   end Error_Number;

end Errors;
