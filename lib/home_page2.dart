// import 'package:flutter/material.dart';

// import 'authentication/bloc/authentication_bloc.dart';
// import 'authentication/bloc/authentication_event.dart';

// class HomePage2 extends StatelessWidget {
//   static Route route() {
//     return MaterialPageRoute<void>(builder: (_) => HomePage2());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home'), actions: <Widget>[
//         ElevatedButton(
//           child: const Text('Logout'),
//           onPressed: () {
//             context
//                 .read<AuthenticationBloc>()
//                 .add(AuthenticationLogoutRequested());
//           },
//         ),
//       ]),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Builder(
//               builder: (BuildContext context) {
//                 final user = context.select(
//                   (AuthenticationBloc bloc) => bloc.state.user,
//                 );
//                 print(user);
//                 final userId = context.select(
//                   (AuthenticationBloc bloc) => bloc.state.user.id,
//                 );

//                 return Text('UserID: $userId');
//               },
//             ),
//             Expanded(
//               child: Container(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
