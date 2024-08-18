import 'package:dio/dio.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // if (getStorage.read(BEARER_TOKEN) != null) {
    //   options.headers['Authorization'] =
    //       'Bearer ${getStorage.read(BEARER_TOKEN)}';
    //   options.headers["Accept"] = "*/*";
    // }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    try {
      if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
        /// LOGOUT
      }
    } catch (e) {
      return super.onError(err, handler);
    }

    return super.onError(err, handler);
  }
}
