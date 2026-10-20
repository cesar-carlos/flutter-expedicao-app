# shared_preferences_android 2.5.x chama o Kotlin por JNI. No release o R8
# renomeia essas classes da stdlib, o getInstance estoura antes do runApp
# e a splash do sistema fica presa. O debug nao ofusca, por isso so o APK
# trava. Pode sair quando o plugin ou o pacote jni publicarem as consumer
# rules: https://github.com/flutter/flutter/issues/194649
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
