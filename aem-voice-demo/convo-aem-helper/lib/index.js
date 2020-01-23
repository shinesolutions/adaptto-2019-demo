/**
 * Retrieve info of this Convo helper library, in this case, package name and version.
 *
 * @return the info
 */
function getInfo() {
  return '%s-%s';
}

/**
 * Trap all api calls in order to install exactly the aem-helloworld package.
 *
 * @param {Object} api: the OpenAPI-generated API object
 * @param {String} method: the name of the method to be executed on the provided API
 * @param {Object} params: query parameters passed from Convo middleware
 * @param {Function} apiCb: callback function to be passed to API method call as the last argument, this method signature is controlled by OpenAPI Generator
 * @param {Function} errCb: callback function with reply text argument, to be called when aem crumb can't be fetched from aem server
 * @param {Object} convoOpts:
 */
function callApi(api, method, params, apiCb, errCb, convoOpts) {
  console.info('Calling API using Convo AEM Helper...');
  const path = 'etc/packages/shinesolutions/aem-helloworld-content-0.0.2.zip';
  const cmd = 'install';
  function cb(err, data, response) {
    if (err) {
      errCb('Unable to process package ABC due to err: ' + err);
    } else {
      apiCb(err, data, response);
    }
  }
  convoOpts.apis.crxApi.postPackageServiceJson(path, cmd, convoOpts, cb);
}

module.exports = {
  getInfo: getInfo,
  callApi: callApi
};
