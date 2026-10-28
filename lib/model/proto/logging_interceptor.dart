import 'dart:developer';

import 'package:grpc/grpc.dart';

/// Interceptor to log raw gRPC traffic for verification
class GrpcLoggingInterceptor implements ClientInterceptor {
  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method, Stream<Q> requests, CallOptions options, ClientStreamingInvoker<Q, R> invoker) {
    log("gRPC STREAM CALL: ${method.path}");
    return invoker(method, requests.map((q) {
      // log("gRPC SENDING MESSAGE: $q");log("gRPC SENDING MESSAGE: $q");
      log("gRPC SENDING MESSAGE");
      return q;
    }), options);
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request, CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    log("gRPC UNARY CALL: ${method.path} | REQ: $request");
    return invoker(method, request, options);
  }
}