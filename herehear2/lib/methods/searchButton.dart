import 'package:flutter/material.dart';

import '../upload.dart';


class SearchButton extends StatefulWidget {
  String currentUser;
  var user_tag;
  SearchButton({this.currentUser, this.user_tag});

  @override
  _SearchButtonState createState() => _SearchButtonState(currentUser: currentUser, user_tag: user_tag);
}

class _SearchButtonState extends State<SearchButton> {
  String currentUser;
  var user_tag;
  _SearchButtonState({this.currentUser, this.user_tag});

  bool showTextField = false;
  Widget _buildFloatingSearchBtn() {
    return IconButton(
      icon: Icon(Icons.search),
      color: showTextField? Theme.of(context).colorScheme.primary : Colors.black,
      onPressed: () {
        setState(() {
          showTextField = !showTextField;
        });
      },
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: Center(
        child: TextField(
          scrollPadding: EdgeInsets.fromLTRB(10, 3, 0, 0),
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 3, 0, 0),
            fillColor: Colors.white,
              filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            hintText: 'Search...',
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          onTap: () {
            showTextField = false;
          },
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          showTextField ? _buildTextField()
              : IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              print('on more check: ${currentUser}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadPage(currentUser: currentUser, user_tag: user_tag),
                ),
              );
            },
          ),
          _buildFloatingSearchBtn(),
        ],
      ),
    );
  }
}

// List<String> allNames = ["ahmed", "ali", "john", "user"];
// var mainColor = Color(0xff1B3954);
// var textColor = Color(0xff727272);
// var accentColor = Color(0xff16ADE1);
// var whiteText = Color(0xffF5F5F5);
//
// class SearchState extends StatelessWidget {
//   String _sortValue;
//   String _ascValue = "ASC";
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             forceElevated: true,
//             elevation: 4,
//             floating: true,
//             snap: true,
//             title: Text(
//               "Search App",
//             ),
//             actions: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.search,
//                 ),
//                 onPressed: () {
//                   showSearch(
//                     context: context,
//                     delegate: CustomSearchDelegate(),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.filter_list,
//                 ),
//                 onPressed: () {
//                   showFilterDialog(context);
//                 },
//               ),
//             ],
//           ),
//         ],
//     );
//   }
//
//   Future<void> showFilterDialog(BuildContext context) {
//     return showDialog(
//         context: context,
//         builder: (BuildContext build) {
//           return StatefulBuilder(builder: (context, setState) {
//             return AlertDialog(
//               title: Center(
//                   child: Text(
//                     "Filter",
//                     style: TextStyle(color: mainColor),
//                   )),
//               content: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     Container(
//                       padding: EdgeInsets.only(top: 12, right: 10),
//                       child: Row(
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.only(right: 16.0),
//                             child: Icon(
//                               Icons.sort,
//                               color: Color(0xff808080),
//                             ),
//                           ),
//                           Expanded(
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 isExpanded: true,
//                                 hint: Text("Sort by"),
//                                 items: <String>[
//                                   "Name",
//                                   "Age",
//                                   "Date",
//                                 ].map((String value) {
//                                   return DropdownMenuItem(
//                                     value: value,
//                                     child: Text(value,
//                                         style: TextStyle(
//                                             color: textColor, fontSize: 16)),
//                                   );
//                                 }).toList(),
//                                 value: _sortValue,
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _sortValue = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.only(top: 8, right: 10),
//                       child: Row(
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.only(right: 16.0),
//                             child: Icon(
//                               Icons.sort_by_alpha,
//                               color: Color(0xff808080),
//                             ),
//                           ),
//                           Expanded(
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 isExpanded: true,
//                                 items: <String>[
//                                   "ASC",
//                                   "DESC",
//                                 ].map((String value) {
//                                   return DropdownMenuItem(
//                                     value: value,
//                                     child: Text(value,
//                                         style: TextStyle(
//                                             color: textColor, fontSize: 16)),
//                                   );
//                                 }).toList(),
//                                 value: _ascValue,
//                                 onChanged: (newValue) {
//                                   setState(() {
//                                     _ascValue = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           });
//         });
//   }
// }
// List<String> searchResult = List();
//
// class CustomSearchDelegate extends SearchDelegate {
//   var suggestion = ["ahmed", "ali", "mohammad"];
//   // List<String> searchResult = List();
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     searchResult.clear();
//     searchResult =
//         allNames.where((element) => element.startsWith(query)).toList();
//     return Container(
//       margin: EdgeInsets.all(20),
//       child: ListView(
//           padding: EdgeInsets.only(top: 8, bottom: 8),
//           scrollDirection: Axis.vertical,
//           children: List.generate(suggestion.length, (index) {
//             var item = suggestion[index];
//             return Card(
//               color: Colors.white,
//               child: Container(padding: EdgeInsets.all(16), child: Text(item)),
//             );
//           })),
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // This method is called everytime the search term changes.
//     // If you want to add search suggestions as the user enters their search term, this is the place to do that.
//     final suggestionList = query.isEmpty
//         ? suggestion
//         : allNames.where((element) => element.startsWith(query)).toList();
//     return ListView.builder(
//       itemBuilder: (context, index) => ListTile(
//         onTap: () {
//           if (query.isEmpty) {
//             query = suggestion[index];
//           }
//         },
//         leading: Icon(query.isEmpty ? Icons.history : Icons.search),
//         title: RichText(
//             text: TextSpan(
//                 text: suggestionList[index].substring(0, query.length),
//                 style:
//                 TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                 children: [
//                   TextSpan(
//                     text: suggestionList[index].substring(query.length),
//                     style: TextStyle(color: textColor),
//                   )
//                 ])),
//       ),
//       itemCount: suggestionList.length,
//     );
//   }
// }
//
//
// class CustomSearchClass extends SearchDelegate {
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
// // this will show clear query button
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
// // adding a back button to close the search
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
// //clear the old search list
//     searchResult.clear();
//
// //find the elements that starts with the same query letters.
// // allNames is a list that contains all your data ( you can replace it here by an http request or a query from your database )
//     searchResult =
//         allNames.where((element) => element.startsWith(query)).toList();
//
// // view a list view with the search result
//     return Container(
//       margin: EdgeInsets.all(20),
//       child: ListView(
//           padding: EdgeInsets.only(top: 8, bottom: 8),
//           scrollDirection: Axis.vertical,
//           children: List.generate(searchResult.length, (index) {
//             var item = searchResult[index];
//             return Card(
//               color: Colors.white,
//               child: Container(padding: EdgeInsets.all(16), child: Text(item)),
//             );
//           })),
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
// // I will add this step as an optional step later
//     return null;
//   }
// }