
// Make sure all installations point to the current user.
Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
  Parse.Cloud.useMasterKey();
  request.object.set('user', request.user);
  response.success();
});
