/*resource "aws_vpc_peering_connection" "managementtocustomervpc" {
  peer_owner_id = "490396566810"
  peer_vpc_id = "${module.customervpc.vpc_id}"
  vpc_id = "${module.vpc.vpc_id}"
  auto_accept = true
}

resource "aws_route" "managetocustpublic" {
  route_table_id = "${module.customervpc.public_route_table_ids[0]}"
  destination_cidr_block = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.managementtocustomervpc.id}"
}

resource "aws_route" "managetocustprivate1" {
  route_table_id = "${module.customervpc.private_route_table_ids[0]}"
  destination_cidr_block = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.managementtocustomervpc.id}"
}

resource "aws_route" "managetocustprivate2" {
  route_table_id = "${module.customervpc.private_route_table_ids[1]}"
  destination_cidr_block = "${module.vpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.managementtocustomervpc.id}"
}

resource "aws_route" "custtomanagepublic" {
  route_table_id = "${module.vpc.public_route_table_ids[0]}"
  destination_cidr_block = "${module.customervpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.managementtocustomervpc.id}"
}

resource "aws_route" "custtomanageprivate" {
  route_table_id = "${module.vpc.private_route_table_ids[0]}"
  destination_cidr_block = "${module.customervpc.vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.managementtocustomervpc.id}"
}
*/