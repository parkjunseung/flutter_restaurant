import 'package:actual/common/const/data.dart';
import 'package:actual/common/secure_storage/secure_storage.dart';
import 'package:actual/user/provider/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(
        ref: ref,
        storage: storage)
  );

  return dio;
});

class CustomInterceptor extends Interceptor {
  final Ref ref;
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.ref,
    required this.storage
  });


  // 1) 요청
  // 요청이 보내질때마다
  // 만약에 요청의 Header에 accessToken : true값이 있다면
  // 실제 토큰을 가져와서 authorization 에 토큰을 대입한다.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    // TODO: implement onRequest
    print('[REQ] [${options.method}] ${options.uri}');

    if(options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if(options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }
    
    return super.onRequest(options, handler);
  }

  // 2) 응답
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[RESP] [${response.requestOptions.method}] [${response.requestOptions.uri}]');

    return super.onResponse(response, handler);
  }

  // 3) 오류
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을때 (status code)
    // 토큰을 재발급 받는 시도를 하교 토큰이 재발급 되면

    print('[ERR] [${err.requestOptions.method}] [${err.requestOptions.uri}]');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken 아예 없으면
    // 당연히 에러를 던진다
    if(refreshToken == null) {
      // 에러를 던질때는 handel
      handler.reject(err);
      return;
    }

    final isStatus401 = err.response?.statusCode == 401;

    final isPathRefresh = err.requestOptions.path == '/auth/token';

    if(isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.post(
            'http://$ip/auth/token',
            options: Options(
                headers: {
                  'authorization' : 'Bearer $refreshToken'
                }
            )
        );
        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        options.headers.addAll({
          'authorization' : 'Bearer $accessToken'
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        final response = await dio.fetch(options);

        return handler.resolve(response);

      }on DioError catch(e) {

        //circular dependency error
        ref.read(authProvider.notifier).logout();
        return handler.reject(e);
      }
    }


    return handler.reject(err);
  }
}