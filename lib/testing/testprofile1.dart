import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userName = "Leo";
  String avatarUrl = "https://m.media-amazon.com/images/I/51TIbI-assL.jpg"; // Replace with real image URL
  String coverPhotoUrl = "https://platform.polygon.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/24458108/captain_pikachu.jpg?quality=90&strip=all&crop=0,3.4613147178592,100,93.077370564282"; // Replace with real image URL
  List<String> photoList = List.generate(9, (index) => "https://static.vecteezy.com/system/resources/previews/024/804/557/non_2x/pikachu-art-or-illustration-on-pickachu-free-vector.jpg"); // Dummy images

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover Photo & Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                // Cover Photo
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverPhotoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -40,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50), // Adjust for avatar overlap

            // User Name
            Text(
              userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Photo Grid (3x3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: photoList.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(photoList[index], fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
