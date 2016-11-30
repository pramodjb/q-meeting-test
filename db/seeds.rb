# ------------------------
# Creating Users and Admin
# ------------------------

user_details = [
	{ name: 'Ajay',email: 'ammuralidhar@qwinixtech.com'},
	{ name: 'Arun',email: 'atmuthe@qwinixtech.com'},
	{ name: 'Pramood',email: 'pjbasavaraju@qwinixtech.com'},
	{ name: 'Suchithra',email: 'sthammaiah@qwinixtech.com'},
	{ name: 'Vidya',email: 'vtshetty@qwinixtech.com'},
	{ name: 'Vijay',email: 'vrsuryaprakash@qwinixtech.com'},
	{ name: 'Krishnaprasad Varma',email: 'kvarma@qwinixtech.com'}
]

user_details.each do |u|
	user = User.new(name: u[:name], email: u[:email], password: User::DEFAULT_PASSWORD)
	if user.save
		puts "Created User #{user.name}"
	else
		puts "Failed to create User #{user.name}"
	end
end

admin_details = [
	{ name: 'Admin',email: 'admin@domain.com'},
	{ name: 'Admin',email: 'admin2@domain.com'}
]

admin_details.each do |a|
	admin = User.new(name: a[:name], email: a[:email], password: User::DEFAULT_PASSWORD)
	if admin.save
		puts "Created Admin User #{admin.name}"
	else
		puts "Failed to create Admin User #{admin.name}"
	end
	admin.add_role :admin
end

# --------------------------------
# Creating Venues & Meeting Rooms
# --------------------------------

venue_details = [
	{ 
		name: 'Mysore', 
		location: 'Qwinix Technologies Pvt. Ltd., Special Plot No. 5, Horizon, HIEMA Convention Center Road, Hebbal Industrial Estate, Mysore – 570016',
		meeting_rooms: [
			{
				name: 'Mysore - 2nd Floor',
				seating_capacity: 4,
				ac: true,
				wifi: true,
				tv: false,
				speaker: false,
				microphone: false,
				projector: false,
			},
			{
				name: 'Costa Rica - 2nd Floor',
				seating_capacity: 6,
				ac: true,
				wifi: true,
				tv: true,
				speaker: true,
				microphone: true,
				projector: false,
			},
			{
				name: 'Dubai - 2nd Floor',
				seating_capacity: 8,
				ac: true,
				wifi: true,
				tv: true,
				speaker: true,
				microphone: true,
				projector: true,
			},
			{
				name: 'Denver - 2nd Floor',
				seating_capacity: 16,
				ac: true,
				wifi: true,
				tv: true,
				speaker: true,
				microphone: true,
				projector: true,
			},
			{
				name: 'Conference Room - 1st Floor',
				seating_capacity: 8,
				ac: true,
				wifi: true,
				tv: false,
				speaker: true,
				microphone: true,
				projector: false,
			},
			{
				name: 'Conference Room - Ground Floor',
				seating_capacity: 8,
				ac: true,
				wifi: true,
				tv: true,
				speaker: false,
				microphone: false,
				projector: false,
			}
		]
	},
	{ name: 'Dubai', location: 'Qwinix Technologies, Level 14, Boulevard Plaza Tower 1, Sheikh Mohammed Bin Rashid Boulevard, Downtown Dubai', meeting_rooms: []},
	{ name: 'Costa Rica', location: 'Qwinix Technologies SA, Centro Corporativo Plaza Roble, Edificio El Portico, Third floor, Escazu, San Jose', meeting_rooms: []},
	{ name: 'Denver', location: 'Qwinix Technologies Inc, Galvanize Boulder, 5th Floor, 1035 Pearl St, Boulder, CO 80302', meeting_rooms: []}
]

venue_details.each do |v|
	venue = Venue.new(name: v[:name], location: v[:location])
	if venue.save
		puts "Created Venue #{venue.name}"
		v[:meeting_rooms].each do |mr|
			meeting_room = MeetingRoom.new
			meeting_room.name = mr[:name]
			meeting_room.seating_capacity = mr[:seating_capacity]
			meeting_room.venue_id = venue.id
			meeting_room.ac = mr[:ac]
			meeting_room.wifi = mr[:wifi]
			meeting_room.tv = mr[:tv]
			meeting_room.speaker = mr[:speaker]
			meeting_room.microphone = mr[:microphone]
			meeting_room.projector = mr[:projector]
			if meeting_room.save
				puts "Created MeetingRoom #{meeting_room.name}"
			else
				puts "Failed to create MeetingRoom #{meeting_room.name}"
			end
		end
	else
		puts "Failed to create Venue #{venue.name}"
	end
end
