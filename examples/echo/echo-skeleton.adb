----------------------------------------------------------------------------
----                                                                    ----
----     This in an example which is hand-written                       ----
----     for the echo object                                            ----
----                                                                    ----
----                package echo_skeletons                              ----
----                                                                    ----
----                authors : Fabien Azavant, Sebastien Ponce           ----
----                                                                    ----
----------------------------------------------------------------------------

with Omniropeandkey ;
with Netbufferedstream ; use Netbufferedstream ;
with Giop_S ; use Giop_S ;

package body Echo.Skeleton is


   -- Dipatch
   ----------
   procedure Dispatch (Self : in out Echo.Impl.Object ;
                       Orls : in out Giop_S.Object ;
                       Orl_Op : in Corba.String ;
                       Orl_Response_Expected : in Corba.Boolean ;
                       Returns : out Corba.Boolean ) is

      Operation_Name : Standard.String := Corba.To_Standard_String(Orl_Op) ;
   begin
      if Operation_Name = "echoString" then
         declare
            Mesg : Corba.String ;
            Result : Corba.String ;
            Mesg_Size : Corba.Unsigned_Long ;
         begin
            Unmarshall(Mesg, Orls) ;

            -- change state
            Request_Received(Orls) ;

            -- call the implementation
            Result := Echo.Impl.EchoString(Self'access, Mesg) ;

            -- computing the size of the replied message
            Mesg_Size := Giop_S.Reply_Header_Size (Orls);
            Mesg_Size := NetbufferedStream.Align_Size (Result,
                                                       Mesg_Size) ;

            -- Initialisation of the reply
            Giop_S.Initialize_Reply (Orls, Mesg_Size) ;

            -- Marshall the arguments (here just a string)
            NetbufferedStream.Marshall (Result, Orls) ;

            -- inform the orb
            Giop_S.Reply_Completed (Orls) ;

            Returns := True ;
            return ;
         end;
      end if ;

      Returns := False ;
      return ;

   end ;

end Echo.Skeleton ;
