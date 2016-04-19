var apiClient = require('panoptes-client/lib/api-client');

var projects = apiClient.type('projects');
var projectPages = apiClient.type('project_pages');

function toSlug(input) {
  return input
    .replace(/\W+/g, ' ')
    .trim()
    .replace(/\s+/g, '-')
    .toLowerCase();
}

var projectPageActions = {
  fetchPagesForProject: function(projectID) {
    return projects.get(projectID).then(function(project) {
      project.uncacheLink('pages');
      return project.get('pages');
    });
  },

  createPageForProject: function(projectID, data) {
    return projects.get(projectID).then(function(project) {
      var payload = {
        project_pages: Object.assign({
          url_key: toSlug(data.title),
          language: project.primary_language
        }, data)
      };
      return apiClient.post(project._getURL('pages'), payload);
    });
  },

  updatePage: function(pageID, data) {
    return projectPages.get(pageID).then(function(page) {
      return page.update(data).save();
    });
  },

  deletePage: function(pageID) {
    return projectPages.get(pageID).then(function(page) {
      return page.delete();
    });
  }
};

module.exports = projectPageActions;
