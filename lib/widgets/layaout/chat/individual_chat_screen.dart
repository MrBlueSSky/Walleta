// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:un_ride/appColors.dart';
// import 'package:un_ride/repository/client_chat/models/client_chat.dart';

// class Message {
//   final String id;
//   final String content;
//   final DateTime timestamp;
//   final bool isFromMe;

//   Message({
//     required this.id,
//     required this.content,
//     required this.timestamp,
//     required this.isFromMe,
//   });
// }

// class IndividualChatScreen extends StatefulWidget {
//   final ClientChat chat;

//   const IndividualChatScreen({super.key, required this.chat});

//   @override
//   State<IndividualChatScreen> createState() => _IndividualChatScreenState();
// }

// class _IndividualChatScreenState extends State<IndividualChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _messageFocusNode = FocusNode();
//   List<Message> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadStaticMessages();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _messageFocusNode.dispose();
//     super.dispose();
//   }

//   void _loadStaticMessages() {
//     _messages = [
//       Message(
//         id: '1',
//         content: 'Hola! ¿Cómo estás?',
//         timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//         isFromMe: false,
//       ),
//       Message(
//         id: '2',
//         content: 'Hola! Todo bien, gracias por preguntar',
//         timestamp: DateTime.now().subtract(
//           const Duration(hours: 1, minutes: 55),
//         ),
//         isFromMe: true,
//       ),
//       Message(
//         id: '3',
//         content: widget.chat.lastMessage,
//         timestamp: widget.chat.lastMessageTime,
//         isFromMe: false,
//       ),
//     ];

//     _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//   }

//   void _acceptApplication() {
//     // TODO: Implementar lógica para aceptar postulación
//     print('Postulación aceptada para: ${widget.chat.userName}');
//   }

//   void _rejectApplication() {
//     // TODO: Implementar lógica para rechazar postulación
//     print('Postulación rechazada para: ${widget.chat.userName}');
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     final newMessage = Message(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       content: _messageController.text.trim(),
//       timestamp: DateTime.now(),
//       isFromMe: true,
//     );

//     setState(() {
//       _messages.add(newMessage);
//       _messageController.clear();
//     });

//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   String _formatMessageTime(DateTime dateTime) {
//     return DateFormat('HH:mm').format(dateTime);
//   }

//   Widget _buildMessageBubble(Message message) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: message.isFromMe ? 64 : 16,
//         right: message.isFromMe ? 16 : 64,
//         bottom: 8,
//       ),
//       child: Column(
//         crossAxisAlignment:
//             message.isFromMe
//                 ? CrossAxisAlignment.end
//                 : CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color:
//                   message.isFromMe
//                       ? AppColors.primary
//                       : AppColors.cardBackground,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               message.content,
//               style: TextStyle(
//                 color: message.isFromMe ? Colors.white : AppColors.textPrimary,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _formatMessageTime(message.timestamp),
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.secondaryBackground,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: [AppColors.primary, AppColors.accentPink],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child:
//                       widget.chat.userAvatar != null
//                           ? ClipRRect(
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.network(
//                               widget.chat.userAvatar!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                           : const Icon(
//                             Icons.person,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                 ),
//                 if (widget.chat.isOnline)
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(
//                           color: AppColors.secondaryBackground,
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.chat.userName,
//                     style: const TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     widget.chat.isOnline ? 'En línea' : 'Desconectado',
//                     style: const TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.close,
//               color: AppColors.textSecondary,
//               size: 22,
//             ),
//             onPressed: _rejectApplication,
//           ),
//           const SizedBox(width: 4),
//           IconButton(
//             icon: const Icon(Icons.check, color: AppColors.primary, size: 22),
//             onPressed: _acceptApplication,
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessageBubble(_messages[index]);
//               },
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               color: AppColors.secondaryBackground,
//               border: Border(
//                 top: BorderSide(color: AppColors.cardBackground, width: 0.5),
//               ),
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.cardBackground,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: TextField(
//                         controller: _messageController,
//                         focusNode: _messageFocusNode,
//                         style: const TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 16,
//                         ),
//                         decoration: const InputDecoration(
//                           hintText: 'Escribe un mensaje...',
//                           hintStyle: TextStyle(
//                             color: AppColors.textSecondary,
//                             fontSize: 16,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   GestureDetector(
//                     onTap: _sendMessage,
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(22),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.primary.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
