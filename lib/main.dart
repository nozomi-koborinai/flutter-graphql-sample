import 'package:flutter/material.dart';
import 'package:flutter_graphql_sample/profile.dart';
import 'package:flutter_graphql_sample/variables.dart';
import 'package:hasura_connect/hasura_connect.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final hasuraConnect = HasuraConnect(graphqlEndpoint);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hasura Flutter Sample'),
        ),
        body: Center(
          child: FutureBuilder(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.error != null) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index]['name']),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<Profile>> getData() async {
    const query = """
    query {
      profiles {
        id
        name
      }
    }
    """;

    final response = await hasuraConnect.query(query);

    if (response is HasuraError) {
      return [];
    }

    final profiles = (response['data']['profiles'] as List)
        .map((profile) => Profile.fromJson(profile))
        .toList();

    return profiles;
  }
}
