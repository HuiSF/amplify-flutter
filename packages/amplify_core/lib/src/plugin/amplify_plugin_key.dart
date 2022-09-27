// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:amplify_core/amplify_core.dart';

/// {@template amplify_core.plugin.amplify_plugin_key}
/// A plugin identifier which can be passed to a category's `getPlugin` method
/// to retrieve a plugin-specific category wrapper.
/// {@endtemplate}
abstract class AmplifyPluginKey<P extends AmplifyPluginInterface>
    with AWSDebuggable {
  /// {@macro amplify_core.plugin.amplify_plugin_key}
  const AmplifyPluginKey();
}

/// {@template amplify_core.plugin.auth_plugin_key}
/// A plugin identifier which can be passed to the Auth category's `getPlugin`
/// method to retrieve a plugin-specific Auth category wrapper.
/// {@endtemplate}
abstract class AuthPluginKey<
    PluginAuthUser extends AuthUser,
    PluginUserAttributeKey extends UserAttributeKey,
    PluginAuthUserAttribute extends AuthUserAttribute<PluginUserAttributeKey>,
    PluginAuthDevice extends AuthDevice,
    PluginSignUpOptions extends SignUpOptions,
    PluginSignUpResult extends SignUpResult,
    PluginConfirmSignUpOptions extends ConfirmSignUpOptions,
    PluginConfirmSignUpResult extends SignUpResult,
    PluginResendSignUpCodeOptions extends ResendSignUpCodeOptions,
    PluginResendSignUpCodeResult extends ResendSignUpCodeResult,
    PluginSignInOptions extends SignInOptions,
    PluginSignInResult extends SignInResult<PluginUserAttributeKey>,
    PluginConfirmSignInOptions extends ConfirmSignInOptions,
    PluginConfirmSignInResult extends SignInResult<PluginUserAttributeKey>,
    PluginSignOutOptions extends SignOutOptions,
    PluginSignOutResult extends SignOutResult,
    PluginUpdatePasswordOptions extends UpdatePasswordOptions,
    PluginUpdatePasswordResult extends UpdatePasswordResult,
    PluginResetPasswordOptions extends ResetPasswordOptions,
    PluginResetPasswordResult extends ResetPasswordResult,
    PluginConfirmResetPasswordOptions extends ConfirmResetPasswordOptions,
    PluginConfirmResetPasswordResult extends UpdatePasswordResult,
    PluginAuthUserOptions extends AuthUserOptions,
    PluginFetchUserAttributeOptions extends FetchUserAttributesOptions,
    PluginAuthSessionOptions extends AuthSessionOptions,
    PluginAuthSession extends AuthSession,
    PluginSignInWithWebUIOptions extends SignInWithWebUIOptions,
    PluginSignInWithWebUIResult extends SignInResult<PluginUserAttributeKey>,
    PluginUpdateUserAttributeOptions extends UpdateUserAttributeOptions,
    PluginUpdateUserAttributeResult extends UpdateUserAttributeResult,
    PluginUpdateUserAttributesOptions extends UpdateUserAttributesOptions,
    PluginConfirmUserAttributeOptions extends ConfirmUserAttributeOptions,
    PluginConfirmUserAttributeResult extends ConfirmUserAttributeResult,
    PluginResendUserAttributeConfirmationCodeOptions extends ResendUserAttributeConfirmationCodeOptions,
    PluginResendUserAttributeConfirmationCodeResult extends ResendUserAttributeConfirmationCodeResult,
    P extends AuthPluginInterface<
        PluginAuthUser,
        PluginUserAttributeKey,
        PluginAuthUserAttribute,
        PluginAuthDevice,
        PluginSignUpOptions,
        PluginSignUpResult,
        PluginConfirmSignUpOptions,
        PluginConfirmSignUpResult,
        PluginResendSignUpCodeOptions,
        PluginResendSignUpCodeResult,
        PluginSignInOptions,
        PluginSignInResult,
        PluginConfirmSignInOptions,
        PluginConfirmSignInResult,
        PluginSignOutOptions,
        PluginSignOutResult,
        PluginUpdatePasswordOptions,
        PluginUpdatePasswordResult,
        PluginResetPasswordOptions,
        PluginResetPasswordResult,
        PluginConfirmResetPasswordOptions,
        PluginConfirmResetPasswordResult,
        PluginAuthUserOptions,
        PluginFetchUserAttributeOptions,
        PluginAuthSessionOptions,
        PluginAuthSession,
        PluginSignInWithWebUIOptions,
        PluginSignInWithWebUIResult,
        PluginUpdateUserAttributeOptions,
        PluginUpdateUserAttributeResult,
        PluginUpdateUserAttributesOptions,
        PluginConfirmUserAttributeOptions,
        PluginConfirmUserAttributeResult,
        PluginResendUserAttributeConfirmationCodeOptions,
        PluginResendUserAttributeConfirmationCodeResult>> extends AmplifyPluginKey<
    P> {
  /// {@macro amplify_core.plugin.auth_plugin_key}
  const AuthPluginKey();
}

// TODO(HuiSF): Define generic parameters for all API types
abstract class StoragePluginKey<
    PluginStorageListOperation extends StorageListOperation,
    PluginStorageListOptions extends StorageListOptions,
    PluginStorageGetPropertiesOperation extends StorageGetPropertiesOperation,
    PluginStorageGetPropertiesOptions extends StorageGetPropertiesOptions,
    PluginStorageGetUrlOperation extends StorageGetUrlOperation,
    PluginStorageGetUrlOptions extends StorageGetUrlOptions,
    PluginStorageUploadDataOperation extends StorageUploadDataOperation,
    PluginStorageUploadDataOptions extends StorageUploadDataOptions,
    PluginStorageCopyOperation extends StorageCopyOperation,
    PluginStorageCopyOptions extends StorageCopyOptions,
    PluginStorageMoveOperation extends StorageMoveOperation,
    PluginStorageMoveOptions extends StorageMoveOptions,
    PluginStorageRemoveOperation extends StorageRemoveOperation,
    PluginStorageRemoveOptions extends StorageRemoveOptions,
    PluginStorageRemoveManyOperation extends StorageRemoveManyOperation,
    PluginStorageRemoveManyOptions extends StorageRemoveManyOptions,
    PluginStorageItem extends StorageItem,
    P extends StoragePluginInterface<
        PluginStorageListOperation,
        PluginStorageListOptions,
        PluginStorageGetPropertiesOperation,
        PluginStorageGetPropertiesOptions,
        PluginStorageGetUrlOperation,
        PluginStorageGetUrlOptions,
        PluginStorageUploadDataOperation,
        PluginStorageUploadDataOptions,
        PluginStorageCopyOperation,
        PluginStorageCopyOptions,
        PluginStorageMoveOperation,
        PluginStorageMoveOptions,
        PluginStorageRemoveOperation,
        PluginStorageRemoveOptions,
        PluginStorageRemoveManyOperation,
        PluginStorageRemoveManyOptions,
        PluginStorageItem>> extends AmplifyPluginKey<P> {
  const StoragePluginKey();
}
