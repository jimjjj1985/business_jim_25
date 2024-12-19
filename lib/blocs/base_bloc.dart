typedef DispatchFunction = T? Function<T>();

abstract class BaseBloc {
  DispatchFunction? dispatch;
  
  void dispose();

}