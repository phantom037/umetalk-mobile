import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  // Sample data
  final String userName = "Leo";
  final String userIntro = "Photography enthusiast | Adventure seeker | Coffee lover\nBased in New York City 📍";
  final String avatarUrl = "https://m.media-amazon.com/images/I/51TIbI-assL.jpg";
  final String coverPhotoUrl = "https://platform.polygon.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/24458108/captain_pikachu.jpg?quality=90&strip=all&crop=0,3.4613147178592,100,93.077370564282";
  final List<String> photoList = List.generate(
      18,
          (index) => "https://static.vecteezy.com/system/resources/previews/024/804/557/non_2x/pikachu-art-or-illustration-on-pickachu-free-vector.jpg"
  );
  final int connections = 1234;
  final int totalPhotos = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Cover photo with avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cover photo
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
                      left: 16,
                      bottom: -50,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Profile info section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name and edit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implement message action
                                },
                                icon: const Icon(Icons.message, size: 20),
                                label: const Text('Message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                      // User introduction
                      const SizedBox(height: 8),
                      Text(
                        userIntro,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStat('Connections', connections),
                          const SizedBox(width: 32),
                          _buildStat('Photos', totalPhotos),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Photo grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index < photoList.length) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(photoList[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                childCount: photoList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}