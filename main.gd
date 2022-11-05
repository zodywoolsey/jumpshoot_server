extends Node3D

@onready var status = $Node2D/status
@onready var userCount = $Node2D/userCount
var usercount = 0
var timer = 0
var peerData :Dictionary = {}

func _process(delta):
	timer += delta
	if timer > 1/15:
		print(peerData)
		syncPlayers()
		timer = 0

func _ready():
	var network = ENetMultiplayerPeer.new()
	network.create_server(2222, 4)
	
	network.connect("peer_connected", peerConnected)
	network.connect("peer_disconnected", peerDisconnected)
	
	multiplayer.connect("peer_packet", packetRecieved)
	
	multiplayer.multiplayer_peer = network

func peerConnected(id):
	status.text += "\nUser " + str(id) + " connected"
	usercount += 1
	userCount.text = str(usercount)
	var tmp = preload("res://remotePlayer.tscn").instantiate()
	tmp.name = str(id)
	#add_child(tmp)

func peerDisconnected(id):
	status.text += "\nUser " + str(id) + " disconnected"
	usercount -= 1
	userCount.text = str(usercount)
	get_node(str(id)).queue_free()
	peerData.erase(str(id))
	multiplayer.send_bytes( var_to_bytes(Array( ["removePlayer", str(id)] )) )

func packetRecieved(id, bytes:PackedByteArray):
	var tmp = bytes_to_var(bytes)
	if tmp is Array:
		if tmp[0] == "player":
			if get_node(str(id)):
				var tmpplayer = get_node(str(id))
				tmpplayer.position = tmp[1]
				tmpplayer.rotation = tmp[2]
				peerData[str(id)] = [tmp[1],tmp[2],tmp[3]]
				#print(tmp)
			else:
				var tmpplayer = preload("res://remotePlayer.tscn").instantiate()
				tmpplayer.name = str(id)
				add_child(tmpplayer)
				peerData[str(id)] = [tmp[1],tmp[2],tmp[3]]
				spawnPlayers(id)
#		elif tmp[0] == "level":
##			print(bytes_to_var_with_objects(tmp)[1])
#			add_child(bytes_to_var_with_objects(tmp[1]).instantiate())

func syncPlayers():
	for peer in peerData:
		multiplayer.send_bytes(var_to_bytes(Array(["playerSync",peerData])),peer.to_int())
func spawnPlayers(id):
	for peer in peerData:
		multiplayer.send_bytes(var_to_bytes(Array(["spawnPlayer",peerData])),peer.to_int())
