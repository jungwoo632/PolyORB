----------------------------------------------------------------------------
----                                                                    ----
----     This in an example which is hand-written                       ----
----     for the echo object                                            ----
----                                                                    ----
----                package echo_proxies                                ----
----                                                                    ----
----                authors : Fabien Azavant, Sebastien Ponce           ----
----                                                                    ----
----------------------------------------------------------------------------

with Corba ;
with Omni ;
with Netbufferedstream ; use Netbufferedstream ;

use type Corba.Unsigned_Long ;


package body Echo.Proxies is

   --------------------------------------------------
   ----        function EchoString               ----
   --------------------------------------------------

   -- Create
   ---------
   function Create(Arg : Corba.String) return EchoString_Proxy is
      Result : EchoString_Proxy ;
   begin
      Init(Result) ;
      Result.Arg_Msg := new Corba.String'(Arg) ;
      return Result ;
   end ;


   -- Operation
   ------------
   function Operation (Self : in EchoString_Proxy)
                       return CORBA.String is
   begin
      return Corba.To_Corba_String("echoString") ;
   end ;


   -- Free
   ----------
   procedure Free(Self : in out EchoString_Proxy) is
   begin
      Corba.Free(Self.Arg_Msg) ;
      Corba.Free(Self.Private_Result) ;
   end ;


   -- Aligned_Size
   --------------
   function Aligned_Size(Self: in EchoString_Proxy;
                         Size_In: in Corba.Unsigned_Long)
                         return Corba.Unsigned_Long is
      Msg_Size : Corba.Unsigned_Long ;
   begin
      Msg_Size := Omni.Align_To(Size_In,Omni.ALIGN_4)
        + Corba.Unsigned_Long(5) + Corba.Length(Self.Arg_Msg.all);
      return Msg_Size ;
   end;

   -- Marshal_Arguments
   -------------------
   procedure Marshal_Arguments(Self: in EchoString_Proxy ;
                               Giop_Client: in Giop_C.Object ) is
   begin
      Marshall(Self.Arg_Msg.all,Giop_Client);
   end;

   -- UnMarshal_Return_Values
   ------------------------
   procedure Unmarshal_Returned_Values(Self: in out EchoString_proxy ;
                                       Giop_Client: in Giop_C.Object) is
      Result : Corba.String ;
   begin
      Unmarshall(Result, Giop_Client) ;
      Self.Private_Result := new Corba.String'(Result) ;
   end ;


   -- Result
   ---------
   function Get_Result (Self : in EchoString_Proxy) return CORBA.String is
   begin
      return Self.Private_Result.all ;
   end ;

end Echo.Proxies ;



