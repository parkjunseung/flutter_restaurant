import 'package:actual/common/component/custom_text_form_field.dart';
import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/defaultLayout.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String user = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final state =ref.watch(userMeProvider);

    return DefaultLayout(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Title(),
                  const SizedBox(height: 16.0,),
                  _SubTitle(),
                  Image.asset(
                    'asset/img/misc/logo.png',
                    width: MediaQuery.of(context).size.width / 3 * 2,
                    height: MediaQuery.of(context).size.width / 3 * 2,
                  ),
                  CustomTextFofmField(
                    onChanged: (String value) {
                      user = value;
                    },
                    hintText: '이메일을 입력해주세요',
                  ),
                  const SizedBox(height: 16.0,),
                  CustomTextFofmField(
                    onChanged: (String value) {
                      password = value;
                    },
                    hintText: '비밀번호를 입력해주세요',
                    obscurText: true,
                  ),
                  ElevatedButton(
                      onPressed: state is UserModelLoading
                          ? null
                          : () async {
                              ref.read(userMeProvider.notifier).login(username: user, password: password);

                              // final rawString = '$user:$password';
                              //
                              // print(rawString);
                              //
                              // Codec<String, String> stringToBase64 = utf8.fuse(base64);
                              //
                              // String token = stringToBase64.encode(rawString);
                              //
                              // final resp = await dio.post('http://$ip/auth/login',
                              //     options: Options(
                              //       headers: {
                              //         'authorization' : 'Basic $token',
                              //       }
                              //     )
                              // );
                              //
                              // final refreshToken = resp.data['refreshToken'];
                              // final accessToken = resp.data['accessToken'];
                              //
                              // final storage = ref.read(secureStorageProvider);
                              //
                              // await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                              // await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
                              //
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //       builder: (_) => RootTab()
                              //   )
                              // );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR
                      ),
                      child: Text(
                          '로그인'
                      )
                  ),
                  TextButton(
                      onPressed: () async {
                        // final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3ODUyMzg4OCwiZXhwIjoxNjc4NjEwMjg4fQ.vKW2c_r75lkhg1BkCApM7fi86nJLJPO587sM0L1GOOY';
                        //
                        // final resp = await dio.post('http://$ip/auth/token',
                        //     options: Options(
                        //         headers: {
                        //           'authorization' : 'Baerer $token',
                        //         }
                        //     )
                        // );
                        //
                        // print(resp.data);

                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black
                      ),
                      child: Text(
                          '회원가입'
                      )
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다.',
      style: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w500,
        color: Colors.black
    ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요! \n오늘도 성공적은 주민이 되길 :)',
      style: TextStyle(
          fontSize: 16.0,
          color: BODY_TEXT_COLOR
      ),
    );
  }
}

