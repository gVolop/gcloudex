defmodule GCloudex.ComputeEngine.Impl do

  @moduledoc """
  
  """

  defmacro __using__(:compute_engine) do 
    quote do 
      use GCloudex.ComputeEngine.Request

      @project_id   GCloudex.get_project_id
      @instance_ep "https://www.googleapis.com/compute/v1/projects/#{@project_id}/zones"
      @no_zone_ep  "https://www.googleapis.com/compute/v1/projects/#{@project_id}"

      ###################
      ### Autoscalers ###
      ###################

      @doc """
      Retrieves a list of autoscalers contained within the specified 'zone' and 
      according to the 'query_params' if provided.
      """
      @spec list_autoscalers(zone :: binary, query_params :: map) :: HTTPResponse.t
      def list_autoscalers(zone, query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/zones/#{zone}/autoscalers", [], "", query
      end

      @doc """
      Returns the specified 'autoscaler' resource if it exists in the given 'zone'.
      """
      @spec get_autoscaler(zone :: binary, autoscaler :: binary, fields :: binary) :: HTTPResponse.t
      def get_autoscaler(zone, autoscaler, fields \\ "") do
        query = fields_binary_to_map fields

        request :get, @no_zone_ep <> "/zones/#{zone}/autoscalers/#{autoscaler}", [], "", query
      end

      @doc """
      Creates an autoscaler in the given 'zone' using the data provided in 
      'autoscaler_resource'.

      For the properties and structure of the 'autoscaler_resource' check
      https://cloud.google.com/compute/docs/reference/latest/autoscalers#resource
      """
      @spec insert_autoscaler(zone :: binary, autoscaler_resource :: Map.t, fields :: binary) :: HTTPResponse.t | no_return
      def insert_autoscaler(zone, autoscaler_resource, fields \\ "") do
        query = fields_binary_to_map fields
        body  = autoscaler_resource |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/autoscalers", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      @doc """
      Updates 'autoscaler_name' in the specified 'zone' using the data included in
      the 'autoscaler_resource'. This function supports patch semantics.
      """
      @spec patch_autoscaler(zone :: binary, autoscaler_name :: binary, autoscaler_resource :: Map.t, fields :: binary) :: HTTPResponse.t
      def patch_autoscaler(zone, autoscaler_name, autoscaler_resource, fields \\ "") do 
        query = 
          if fields == "" do 
            %{"autoscaler" => autoscaler_name} |> URI.encode_query
          else
            %{"autoscaler" => autoscaler_name, "fields" => fields} |> URI.encode_query
          end

        body  = autoscaler_resource |> Poison.encode!

        request(
          :patch, 
          @no_zone_ep <> "/zones/#{zone}/autoscalers", 
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Updates an autoscaler in the specified 'zone' using the data included in 
      the 'autoscaler_resource'. The 'autoscaler_name' may be provided but it's
      optional.
      """
      @spec update_autoscaler(zone :: binary, autoscaler_name :: binary, autoscaler_resource :: Map.t, fields :: binary) :: HTTPResponse.t
      def update_autoscaler(zone, autoscaler_name \\ "", autoscaler_resource, fields \\ "") do
        body  = autoscaler_resource |> Poison.encode!
        query = 
          case {autoscaler_name == "", fields == ""} do 
            {true, true} ->
              ""
            {true, false} ->
              %{"fields" => fields} |> URI.encode_query
            {false, true} ->
              %{"autoscaler" => autoscaler_name} |> URI.encode_query
            {false, false} ->
              %{"autoscaler" => autoscaler_name, "fields" => fields} |> URI.encode_query
          end    

        request(
          :put, 
          @no_zone_ep <> "/zones/#{zone}/autoscalers",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Deletes the specified 'autoscaler' if it exists in the given 'zone'.
      """
      @spec delete_autoscaler(zone :: binary, autoscaler :: binary, fields :: binary) :: HTTPResponse.t
      def delete_autoscaler(zone, autoscaler, fields \\ "") do
        query = fields_binary_to_map fields

        request(:delete, @no_zone_ep <> "/zones/#{zone}/autoscalers/#{autoscaler}", [], "", query)
      end

      @doc """
      Retrieves an aggregated list of autoscalers according to the given 
      'query_params' if provided.
      """
      @spec aggregated_list_of_autoscalers(map) :: HTTPResponse.t
      def aggregated_list_of_autoscalers(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request(:get, @no_zone_ep <> "/aggregated/autoscalers", [], "", query)
      end 
      
      #################
      ### DiskTypes ###
      #################

      @doc """
      Retrieves a list of disk types available to the specified 'zone' according
      to the given 'query_params' if provided.
      """
      @spec list_disk_types(binary, map) :: HTTPResponse.t
      def list_disk_types(zone, query_params \\ %{}) do 
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/zones/#{zone}/diskTypes", [], "", query
      end
      
      @doc """
      Returns the specified 'disk_type' if it exists in the given 'zone'.
      """
      @spec get_disk_type(binary, binary, binary) :: HTTPResponse.t
      def get_disk_type(zone, disk_type, fields \\ "") do
        if not Regex.match?(~r/$[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?/, disk_type) do 
          raise ArgumentError, 
            message: "The disk type must match the regular expression "
                     <> "'[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?'."
        end

        query = fields_binary_to_map fields

        request(
          :get, 
          @no_zone_ep <> "/zones/#{zone}/diskTypes/#{disk_type}",
          [],
          "",
          query)
      end

      @doc """
      Retrieves an aggregated list of Disk Types according to the
      'query_params' if provided.
      """
      @spec aggregated_list_of_disk_types(map) :: HTTPResponse.t
      def aggregated_list_of_disk_types(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/aggregated/diskTypes", [], "", query
      end  

      #############
      ### Disks ###
      #############

      @doc """
      Retrieves a list of persistent disks contained within the specified 'zone' and
      according to the given 'query_params' if provided.
      """
      @spec list_disks(binary, map) :: HTTPResponse.t
      def list_disks(zone, query_params \\ %{}) do
        query = query_params |> URI.encode_query
        
        request :get, @no_zone_ep <> "/zones/#{zone}/disks", [], "", query
      end

      @doc """
      Returns a specified persistent 'disk' if it exists in the given 'zone'. The
      HTTP reply contains a Disk Resource in the body.
      """
      @spec get_disk(binary, binary, binary) :: HTTPResponse.t
      def get_disk(zone, disk, fields \\ "") do
        query = fields_binary_to_map fields  

        request :get, @no_zone_ep <> "/zones/#{zone}/disks/#{disk}", [], "", query
      end

      @doc """
      Creates a persistent disk in the specified 'zone' using the data in the 
      'disk_resource'. You can create a disk with a 'source_image' or a 
      sourceSnapshot (provided in the 'disk_resource'), or create an empty 500 GB 
      data disk by omitting all properties. You can also create a disk that is 
      larger than the default size by specifying the sizeGb property in the 
      'disk_resource'.
      """
      @spec insert_disk(binary, map, binary, binary) :: HTTPResponse.t
      def insert_disk(zone, disk_resource, source_image \\ "", fields \\ "") do 
        if not Map.has_key?(disk_resource, "name") do 
          raise ArgumentError, message: "The Disk Resource must contain at least the 'name' key."
        end

        query = 
          if source_image != "" do 
            fields_binary_to_map(fields) <> "&sourceImage=#{source_image}"
          else
            fields_binary_to_map fields
          end

        body = disk_resource |> Poison.encode!

        request(
          :post,
          @no_zone_ep <> "/zones/#{zone}/disks",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Deletes the specified persistent 'disk' if it exists in the given 'zone'.
      """
      @spec delete_disk(binary, binary, binary) :: HTTPResponse.t
      def delete_disk(zone, disk, fields \\ "") do
        query = fields_binary_to_map fields

        request :delete, @no_zone_ep <> "/zones/#{zone}/disks/#{disk}", [], "", query
      end

      @doc """
      Resizes the specified persistent 'disk' if it exists in the given 'zone' to 
      the provided 'size_gb'.
      """
      @spec resize_disk(binary, binary, pos_integer, binary) :: HTTPResponse.t
      def resize_disk(zone, disk, size_gb, fields \\ "") when size_gb > 0 do 
        query = fields_binary_to_map fields
        body  = %{"sizeGb" => size_gb} |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/disks/#{disk}/resize", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      @doc """
      Retrieves an aggregated list of persistent disks according to the given
      'query_params' if they're provided.
      """
      @spec aggregated_list_of_disks(map) :: HTTPResponse.t
      def aggregated_list_of_disks(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/aggregated/disks", [], "", query
      end
      
      @doc """
      Creates a snapshot of a specified persistent 'disk' if it exists in the
      given 'zone' and according to the given 'resource'. The 'request' map must
      contain the keys "name" and "description" and "name" must obey the 
      refex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'.
      """
      @spec create_snapshot(binary, binary, map, binary) :: HTTPResponse.t
      def create_snapshot(zone, disk, request, fields \\ "") do

        if request == %{} do 
          raise ArgumentError, 
            message: "The request cannot be empty. At least keys 'name' "
                     <> "and 'description' must be provided."
        end

        query = fields_binary_to_map fields
        body  = request |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/disks/#{disk}/createSnapshot",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end      

      #################
      ### Firewalls ###
      ################# 

      @doc """
      Retrieves the list of firewall rules according to the 'query_params' if 
      provided.
      """
      @spec list_firewalls(map) :: HTTPResponse.t
      def list_firewalls(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/global/firewalls", [], "", query
      end

      @doc """
      Returns the specified 'firewall'.
      """
      @spec get_firewall(binary, binary) :: HTTPResponse.t
      def get_firewall(firewall, fields \\ "") do
        query = fields_binary_to_map fields

        request :get, @no_zone_ep <> "/global/firewalls/#{firewall}", [], "", query
      end

      @doc """
      Creates a new firewall using the data included in 'firewall_resource'. For 
      information about the structure and properties of Firewall Resources check
      https://cloud.google.com/compute/docs/reference/latest/firewalls#resource
      """
      @spec insert_firewall(map, binary) :: HTTPResponse.t
      def insert_firewall(firewall_resource, fields \\ "") when is_map(firewall_resource) do
        query = fields_binary_to_map fields
        body  = firewall_resource |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/global/firewalls", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      @doc """
      Updates the specified 'firewall' rule with the data included in the 
      'firewall_resource'. This function supports patch semantics.
      """
      @spec patch_firewall(binary, map, binary) :: HTTPResponse.t
      def patch_firewall(firewall, firewall_resource, fields \\ "") when is_map(firewall_resource) do
        query = fields_binary_to_map fields
        body  = firewall_resource |> URI.encode_query

        request(
          :patch, 
          @no_zone_ep <> "/global/firewalls/#{firewall}", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      @doc """
      Updates the specified 'firewall' rule with the data included in the 
      'firewall_resource'.
      """
      @spec update_firewall(binary, map, binary) :: HTTPResponse.t
      def update_firewall(firewall, firewall_resource, fields \\ "") when is_map(firewall_resource) do
        query = fields_binary_to_map fields
        body  = firewall_resource |> URI.encode_query

        request(
          :put, 
          @no_zone_ep <> "/global/firewalls/#{firewall}", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)    
      end

      @doc """
      Deletes the specified 'firewall'.
      """
      @spec delete_firewall(binary, binary) :: HTTPResponse.t
      def delete_firewall(firewall, fields \\ "") do
        query = fields_binary_to_map fields

        request(
          :delete,
          @no_zone_ep <> "/global/firewalls/#{firewall}",
          [],
          "",
          query)
      end  

      ##############
      ### Images ###
      ##############

      @doc """
      Retrieves the list of private images available (project scoped only).
      """
      @spec list_images(map) :: HTTPResponse.t
      def list_images(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/global/images", [], "", query
      end

      @doc """
      Returns the specified 'image'.
      """
      @spec get_image(binary, binary) :: HTTPResponse.t
      def get_image(image, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end  

        request(:get, @no_zone_ep <> "/global/images/#{image}", [], "", query)
      end

      @doc """
      Creates an image with the provided 'image_resource'.
      """
      @spec insert_image_with_resource(map, binary) :: HTTPResponse.t
      def insert_image_with_resource(image_resource, fields \\ "") when is_map(image_resource) do 
        body  = image_resource |> Poison.encode!
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end      

        request(
          :post, 
          @no_zone_ep <> "/global/images", 
          [{"Content-Type", "application/json"}], 
          body,
          query)    
      end

      @doc """
      Creates an image with the given 'name' and 'source_url'. This function uses
      the minimal amount of parameters needed to build the image. For a more 
      detailed image creation use insert_image_with_resource/2 where more complex 
      Image Resources can be passed.
      """
      @spec insert_image(binary, binary, binary) :: HTTPResponse.t
      def insert_image(name, source_url, fields \\ "") do
        body  = %{"name" => name, "rawDisk" => %{"source" => source_url}} |> Poison.encode!
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end  

        request(
          :post, 
          @no_zone_ep <> "/global/images", 
          [{"Content-Type", "application/json"}], 
          body,
          query)
      end

      @doc """
      Deletes the specified 'image'.
      """
      @spec delete_image(binary, binary) :: HTTPResponse.t
      def delete_image(image, fields \\ "") do
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end  

        request(:delete, @no_zone_ep <> "/global/images/#{image}", [], "", query)
      end

      @doc """
      Sets the deprecation status of an 'image' using the data provided in the
      'request_params'. 
      """
      @spec deprecate_image(binary, map, binary) :: HTTPResponse.t
      def deprecate_image(image, request_params, fields \\ "") do 
        body  = request_params |> Poison.encode!
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :post,
          @no_zone_ep <> "/global/images/#{image}/deprecate", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end  

      ######################
      ### InstanceGroups ###
      ######################

      @doc """
      Retrieves the list of instance groups that are located in the 
      specified 'zone'.
      """
      @spec list_instance_groups(binary, map) :: HTTPResponse.t
      def list_instance_groups(zone, query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/zones/#{zone}/instanceGroups", [], "", query
      end

      @doc """
      Lists the instances in the specified 'instance_group' if it exists in the 
      given 'zone'. A filter for the state of the instances can be passed
      through 'instance_state'.
      """
      @spec list_instances_in_group(binary, binary, binary, map) :: HTTPResponse.t
      def list_instances_in_group(zone, instance_group, instance_state \\ "", query_params \\ %{}) do
        query = query_params |> URI.encode_query
        body  = %{"instanceState" => instance_state} |> Poison.encode!

        request(
          :post,
          @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}/listInstances",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end
      
      @doc """
      Returns the specified 'instance_group' if it exists in the given 'zone'.
      """
      @spec get_instance_group(binary, binary, binary) :: HTTPResponse.t
      def get_instance_group(zone, instance_group, fields \\ "") do
        query = fields_binary_to_map fields

        request(:get, @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}", [], "", query)
      end

      @doc """
      Creates an Instance Group in the specified 'zone' using the data provided
      in 'instance_group_resource'. For the structure and properties required in
      the Instance Group Resources check
      https://cloud.google.com/compute/docs/reference/latest/instanceGroups#resource
      """
      @spec insert_instance_group(binary, map, binary) :: HTTPResponse.t
      def insert_instance_group(zone, instance_group_resource, fields \\ "") when is_map(instance_group_resource) do
        query = fields_binary_to_map fields
        body  = instance_group_resource |> Poison.encode!
        
        request(
          :post,
          @no_zone_ep <> "/zones/#{zone}/instanceGroups",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Deletes the specified 'instance_group' if it exists in the given 'zone'.
      """
      @spec delete_instance_group(binary, binary, binary) :: HTTPResponse.t
      def delete_instance_group(zone, instance_group, fields \\ "") do
        query = fields_binary_to_map fields

        request(
          :delete,
          @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}",
          [],
          "",
          query) 
      end

      @doc """
      Retrieves the list of Instance Groups and sorts them by zone.
      """
      @spec aggregated_list_of_instance_groups(map) :: HTTPResponse.t
      def aggregated_list_of_instance_groups(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request(:get, @no_zone_ep <> "/aggregated/instanceGroups", [], "", query)
      end

      @doc """
      Adds a list of 'instances' to the specified 'instance_group' if it exists in
      the given 'zone'.
      """
      @spec add_instances_to_group(binary, binary, [binary], binary) :: HTTPResponse.t
      def add_instances_to_group(zone, instance_group, instances, fields \\ "") do
        query = fields_binary_to_map fields
        body  = %{"instances" => build_list_of_instances(instances, [])}
        |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}/addInstances", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      @doc """
      Removes the 'instances' from the provided 'instance_group' if it exists in
      the given 'zone'.
      """
      @spec remove_instances_from_group(binary, binary, [binary], binary) :: HTTPResponse.t
      def remove_instances_from_group(zone, instance_group, instances, fields \\ "") do
        query = fields_binary_to_map fields
        body  = %{"instances" => build_list_of_instances(instances, [])}
        |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}/removeInstances", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)    
      end

      @doc """
      Sets the named 'ports' for the specified 'instance_group' if it exists in the
      given 'zone'. The 'ports' must be passed as a list of tuples with the format
      {<name>, <port>}.
      """
      @spec set_named_ports_for_group(binary, binary, [{binary, binary}], binary, binary) :: HTTPResponse.t
      def set_named_ports_for_group(zone, instance_group, ports, fingerprint \\ "", fields \\ "") do
        query = fields_binary_to_map fields
        body  = %{"namedPorts" => build_list_of_ports(ports, [])}

        body = 
          if fingerprint != "" do 
            body |> Map.put_new("fingerprint", fingerprint) |> Poison.encode!
          else
            body |> Poison.encode!
          end

        request(
          :post, 
          @no_zone_ep <> "/zones/#{zone}/instanceGroups/#{instance_group}/setNamedPorts", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end

      defp build_list_of_instances([head | []], state), do: state ++ [%{"instance" => head}]
      defp build_list_of_instances([head | tail], state) do
        build_list_of_instances tail, state ++ [%{"instance" => head}]
      end

      defp build_list_of_ports([_head = {name, port} | []], state), do: state ++ [%{"name" => name, "port" => port}]
      defp build_list_of_ports([_head = {name, port} | tail], state) do 
        build_list_of_ports tail, state ++ [%{"name" => name, "port" => port}]
      end  

      #################
      ### Instances ###
      #################

      @doc """
      Lists all instances in the given 'zone' obeying the given 'query_params' if
      present.
      """
      @spec list_instances(binary, map) :: HTTPResponse.t
      def list_instances(zone, query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @instance_ep <> "/#{zone}/instances", [], "", query
      end

      @doc """
      Returns the data about the 'instance' in the given 'zone' if it exists.
      """
      @spec get_instance(binary, binary, binary) :: HTTPResponse.t
      def get_instance(zone, instance, fields \\ "") do
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :get, 
          @instance_ep <> "/#{zone}/instances/#{instance}", 
          [], 
          "",
          query)
      end

      @doc """
      Creates a new Virtual Machine instance on Google Compute Engine in the given
      'zone' and with properties defined in 'instance_resource'. Example of the 
      minimal Instance Resource the API will accept:

        %{
          "disks" => 
          [
            %{
              "autoDelete" => true, "boot" => true,
              "initializeParams" => 
              %{
                "sourceImage" => 
                  "projects/debian-cloud/global/images/debian-8-jessie-v20160119"
                },
              "type" => "PERSISTENT"
            }
          ],
          "machineType" => "zones/europe-west1-d/machineTypes/f1-micro",
          "name" => "example-instance",
          "networkInterfaces" => 
          [
            %{
              "accessConfigs" => 
              [
                %{
                 "name" => "External NAT",
                 "type" => "ONE_TO_ONE_NAT"
                }
             ], 
             "network" => "global/networks/default"
            }
          ]
        }

      For the 'instance_resource' check the documentation at:

        https://cloud.google.com/compute/docs/reference/latest/instances#resource
      """
      @spec insert_instance(binary, map, binary) :: HTTPResponse.t
      def insert_instance(zone, instance_resource, fields \\ "") do
        body  = instance_resource |> Poison.encode!
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :post, 
          @instance_ep <> "/#{zone}/instances", 
          [{"Content-Type", "application/json"}], 
          body,
          query)
      end

      @doc """
      Deletes the given 'instance' if it exists in the given 'zone'.
      """
      @spec delete_instance(binary, binary, binary) :: HTTPResponse.t
      def delete_instance(zone, instance, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :delete, 
          @instance_ep <> "/#{zone}/instances/#{instance}", 
          [], 
          "",
          query)
      end

      @doc """
      Starts a stopped 'instance' if it exists in the given 'zone'.
      """
      @spec start_instance(binary, binary, binary) :: HTTPResponse.t
      def start_instance(zone, instance, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end    

        request( 
          :post, 
          @instance_ep <> "/#{zone}/instances/#{instance}/start", 
          [{"Content-Type", "application/json"}], 
          "",
          query)
      end

      @doc """
      Stops a running 'instance' if it exists in the given 'zone'.
      """
      @spec stop_instance(binary, binary, binary) :: HTTPResponse.t
      def stop_instance(zone, instance, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :post, 
          @instance_ep <> "/#{zone}/instances/#{instance}/stop", 
          [{"Content-Type", "application/json"}], 
          "",
          query)
      end

      @doc """
      Performs a hard reset on the 'instance' if it exists in the given 'zone'.
      """
      @spec reset_instance(binary, binary, binary) :: HTTPResponse.t
      def reset_instance(zone, instance, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :post, 
          @instance_ep <> "/#{zone}/instances/#{instance}/reset",
          [{"Content-Type", "application/json"}], 
          "",
          query)      
      end

      @doc """
      Adds an access config to the 'instance' if it exists in the given 'zone'. The
      kind and type will automatically be added with the default (and only possible)
      values.
      """
      @spec add_access_config(binary, binary, binary, binary, binary, binary) :: HTTPResponse.t
      def add_access_config(zone, instance, network_interface, name, nat_ip \\ "", fields \\ "") do 
        body = 
          %{
            "kind"  => "compute#accessConfig",
            "type"  => "ONE_TO_ONE_NAT",
            "name"  => name
          }    

        body = 
          if nat_ip != "" do 
            body |> Map.put_new("natIP", nat_ip)
          else
            body
          end

        query = 
          if fields == "" do 
            %{"networkInterface" => network_interface} |> URI.encode_query
          else
            %{"networkInterface" => network_interface, "fields" => fields} 
            |> URI.encode_query
          end


        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/addAccessConfig",
          [{"Content-Type", "application/json"}],
          body |> Poison.encode!,
          query)
      end

      @doc """
      Deletes te 'access_config' from the 'instance' 'network_interface' if the
      'instance' exists in the given 'zone'.
      """
      @spec delete_access_config(binary, binary, binary, binary, binary) :: HTTPResponse.t
      def delete_access_config(zone, instance, access_config, network_interface, fields \\ "") do 
        query = 
          if fields == "" do 
            %{"accessConfig" => access_config, "networkInterface" => network_interface}
            |> URI.encode_query
          else
            %{
              "accessConfig"     => access_config, 
              "networkInterface" => network_interface,
              "fields"           => fields
            }
          |> URI.encode_query
          end    

        request(
          :post, 
          @instance_ep <> "/#{zone}/instances/#{instance}/deleteAccessConfig",
          [{"Content-Type", "application/json"}],
          "",
          query)
      end

      @doc """
      Retrieves aggregated list of instances according to the specified 
      'query_params' if present.
      """
      @spec get_aggregated_list_of_instances(map) :: HTTPResponse.t
      def get_aggregated_list_of_instances(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request(
          :get, 
          @no_zone_ep <> "/aggregated/instances",
          [],
          "",
          query)
      end

      @doc """
      Attaches the 'disk_resource' to the 'instance' if it exists in the given
      'zone'.

      Disk Resource structure:

        {
          "kind": "compute#attachedDisk",
          "index": integer,
          "type": string,
          "mode": string,
          "source": string,
          "deviceName": string,
          "boot": boolean,
          "initializeParams": {
            "diskName": string,
            "sourceImage": string,
            "diskSizeGb": long,
            "diskType": string
          },
          "autoDelete": boolean,
          "licenses": [
            string
          ],
          "interface": string
        }
      """
      @spec attach_disk(binary, binary, map, binary) :: HTTPResponse.t
      def attach_disk(zone, instance, disk_resource, fields \\ "") do
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :post, 
          @instance_ep <> "/#{zone}/instances/#{instance}/attachDisk",
          [{"Content-Type", "application/json"}],
          disk_resource |> Poison.encode!,
          query)
      end

      @doc """
      Detaches the disk with 'device_name' from the 'instance' if it exists in the
      given 'zone'.
      """
      @spec detach_disk(binary, binary, binary, binary) :: HTTPResponse.t
      def detach_disk(zone, instance, device_name, fields \\ "") do
        query = 
          if fields == "" do 
            %{"deviceName" => device_name} |> URI.encode_query 
          else
            %{"deviceName" => device_name, "fields" => fields} |> URI.encode_query
          end    

        request(
          :get, 
          @instance_ep <> "/#{zone}/instances/#{instance}/detachDisk",
          [{"Content-Type", "application/json"}],
          "",
          query)
      end

      @doc """
      Sets the 'auto_delete' flag for the disk with 'device_name' attached to 
      'instance' if it exists in the given 'zone'.
      """
      @spec set_disk_auto_delete(binary, binary, boolean, binary, binary) :: HTTPResponse.t
      def set_disk_auto_delete(zone, instance, auto_delete, device_name, fields \\ "") do 
        query = 
          if fields == "" do 
            %{"deviceName" => device_name, "autoDelete" => auto_delete}
            |> URI.encode_query
          else
            %{
              "deviceName" => device_name, 
              "autoDelete" => auto_delete,
              "fields"     => fields
            }
            |> URI.encode_query
          end

        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/setDiskAutoDelete",
          [{"Content-Type", "application/json"}],
          "",
          query)
      end

      @doc """
      Returns the specified 'instance' serial 'port' output if the 'instance'
      exists in the given 'zone'. The 'port' accepted values are from 1 to 4, 
      inclusive.
      """
      @spec get_serial_port_output(binary, binary, pos_integer, binary) :: HTTPResponse.t
      def get_serial_port_output(zone, instance, port \\ 1, fields \\ "") do 
        port = 
          if port == 1 do 
            port
          else
            port
          end

        query = 
          if fields == "" do         
            %{"port" => port} |> URI.encode_query
          else
            %{"port" => port, "fields" => fields} |> URI.encode_query
          end
        
        request(
          :get, 
          @instance_ep <> "/#{zone}/instances/#{instance}/serialPort",
          [],
          "",
          query)
      end

      @doc """
      Changes the Machine Type for a stopped 'instance' to the specified 
      'machine_type' if the 'instance' exists in the given 'zone'.
      """
      @spec set_machine_type(binary, binary, binary, binary) :: HTTPResponse.t
      def set_machine_type(zone, instance, machine_type, fields \\ "") do 
        body = %{"machineType" => machine_type} |> Poison.encode!
        query = 
          if fields == "" do
            fields
          else
            %{"fields" => fields}
          end

        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/setMachineType",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Sets metadata for the specified 'instance' to the data specified in 
      'fingerprint' and 'items'. The 'instance' must exist in the given 'zone'.

      The 'items' should be passed as a list of maps:
        [
          %{
            "key"   => "some key value",
            "value" => "some value"
          },
          %{
            "key"   => "some other key value",
            "value" => "some other value"
          }
        ]
      """
      @spec set_metadata(binary, binary, binary, list(map), binary) :: HTTPResponse.t
      def set_metadata(zone, instance, fingerprint, items, fields \\ "") do 
        body = %{"kind" => "compute#metadata"}
        |> Map.put_new("fingerprint", fingerprint)
        |> Map.put_new("items", items)
        |> Poison.encode!

        query = 
          if fields == "" do
            fields
          else
            %{"fields" => fields}
          end    

        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/setMetadata",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Sets an 'instance' scheduling options if it exists in the given 'zone'. The
      'preemptible' option cannot be changed after instance creation.
      """
      @spec set_scheduling(binary, binary, {binary, boolean, boolean}, binary) :: HTTPResponse.t
      def set_scheduling(zone, instance, {on_host_maintenance, automatic_restart, preemptible}, fields \\ "") do 
        body = %{
                  "onHostMaintenance" => on_host_maintenance, 
                  "automaticRestart"  => automatic_restart,
                  "preemptible"       => preemptible
                }
        |> Poison.encode!

        query = 
          if fields == "" do
            fields
          else
            %{"fields" => fields}
          end

        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/setScheduling",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end

      @doc """
      Sets tags for the specified 'instance' to the given 'fingerprint' and 'items'.
      The 'instance' must exist in the given 'zone'.
      """
      @spec set_tags(binary, binary, binary, list(binary), binary) :: HTTPResponse.t
      def set_tags(zone, instance, fingerprint, items, fields \\ "") do 
        body = %{"fingerprint" => fingerprint, "items" => items} |> Poison.encode!
        query = 
          if fields == "" do
            fields
          else
            %{"fields" => fields}
          end    

        request(
          :post,
          @instance_ep <> "/#{zone}/instances/#{instance}/setTags",
          [{"Content-Type", "application/json"}],
          body,
          query)
      end  

      ################
      ### Licenses ###
      ################

      @doc """
      Returns the specified 'license' resource.
      """
      @spec get_license(binary, binary) :: HTTPResponse.t
      def get_license(license, fields \\ "") do
        query = fields_binary_to_map fields

        request :get, @no_zone_ep <> "/global/licenses/#{license}", [], "", query
      end  

      #####################
      ### Machine Types ###
      #####################

      @doc """
      Retrieves a list of machine types available in the specified 'zone' and 
      that fit in the given 'query_params' if present.
      """
      @spec list_machine_types(binary, map) :: HTTPResponse.t
      def list_machine_types(zone, query_params \\ %{}) do 
        query = query_params |> URI.encode_query

        request(:get, @instance_ep <> "/#{zone}/machineTypes", [], "", query)
      end

      @doc """
      Returns the specified 'machine_type' in the given 'zone'.
      """
      @spec get_machine_type(binary, binary, binary) :: HTTPResponse.t
      def get_machine_type(zone, machine_type, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request(
          :get, 
          @instance_ep <> "/#{zone}/machineTypes/#{machine_type}", 
          [], 
          "", 
          query)
      end

      @doc """
      Returns an aggragated list of machine types following the specified 
      'query_params' if present.
      """
      @spec get_aggregated_list_of_machine_types(map) :: HTTPResponse.t
      def get_aggregated_list_of_machine_types(query_params \\ %{}) do 
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/aggregated/machineTypes", [], "", query
      end      

      ################
      ### Networks ###
      ################

      @doc """
      Retrieves the list of networks available according to the given 
      'query_params' if provided.
      """
      @spec list_networks(map) :: HTTPResponse.t
      def list_networks(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/global/networks", [], "", query
      end

      @doc """
      Returns the speciefied 'network'.
      """
      @spec get_network(binary, binary) :: HTTPResponse.t
      def get_network(network, fields \\ "") do
        query = fields_binary_to_map fields

        request :get, @no_zone_ep <> "/global/networks/#{network}", [], "", query
      end

      @doc """
      Creates a network using the data specified in 'network_resource'. To read
      about the structure and properties of the Network Resource check
      https://cloud.google.com/compute/docs/reference/latest/networks#resource.
      """
      @spec insert_network(map, binary) :: HTTPResponse.t | no_return
      def insert_network(network_resource, fields \\ "") when is_map(network_resource) do
        if not "name" in Map.keys(network_resource) do 
          raise ArgumentError, message: "The 'name' property is required in the Network Resource."
        end

        query = fields_binary_to_map fields
        body  = network_resource |> Poison.encode!

        request(
          :post, 
          @no_zone_ep <> "/global/networks", 
          [{"Content-Type", "application/json"}], 
          body, 
          query)
      end
      
      @doc """
      Deletes the specified 'network'.
      """
      @spec delete_network(binary, binary) :: HTTPResponse.t
      def delete_network(network, fields \\ "") do
        query = fields_binary_to_map fields

        request(
          :delete,
          @no_zone_ep <> "/global/networks/#{network}",
          [], 
          "",
          query)
      end  

      ###############
      ### Regions ###
      ###############

      @doc """
      Retrieves a list of region resources according to the given 'query_params'.
      """
      @spec list_regions(map) :: HTTPResponse.t
      def list_regions(query_params \\ %{}) do
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/regions", [], "", query
      end    

      @doc """
      Returns the specified 'region' resource.
      """
      @spec get_region(binary, binary) :: HTTPResponse.t
      def get_region(region, fields \\ "") do 
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end

        request :get, @no_zone_ep <> "/regions/#{region}", [], "", query
      end  

      #############
      ### Zones ###
      #############

      @doc """
      Retrieves the list of Zone resources available according to the given
      'query_params'.
      """
      @spec list_zones(map) :: HTTPResponse.t
      def list_zones(query_params \\ %{}) do 
        query = query_params |> URI.encode_query

        request :get, @no_zone_ep <> "/zones", [], "", query
      end  

      @doc """
      Returns the specified 'zone' resource. 
      """
      @spec get_zone(binary, binary) :: HTTPResponse.t
      def get_zone(zone, fields \\ "") do
        query = 
          if fields == "" do 
            fields
          else
            %{"fields" => fields} |> URI.encode_query
          end   
          
        request :get, @no_zone_ep <> "/zones/#{zone}", [], "", query
      end

      ###############
      ### Helpers ###
      ###############

      defp fields_binary_to_map(fields) do 
        if fields == "" do 
          fields
        else
          %{"fields" => fields} |> URI.encode_query
        end  
      end    
    end
  end
  
end