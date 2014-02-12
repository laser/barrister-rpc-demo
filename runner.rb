require_relative './client/session'
require_relative './lib/barrister_intra_process_container'
require_relative './service/user_service'

container  = Barrister::IntraProcessContainer.new './service/user_service.json', UserService
transport  = Barrister::IntraProcessTransport.new container
rpc_client = Barrister::Client.new transport
session    = TerminalClient::Session.new rpc_client
session.begin
