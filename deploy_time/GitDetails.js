dt.controls.GitDetails = dt.controls.Control.extend({

	/**
	 * @param {Object} [options]
	 * @param {dt.entities.AssetDetails} options.assetDetails
	 * @param {dt.entities.GitDetails} options.gitDetailsUi
	 * @param {dt.entities.GitDetails} options.gitDetailsCore
	 */
	init: function method (options) {

		options = options || {};

		// Properties.
		this._assetDetails = options.assetDetails;
		this._gitDetailsUi = options.gitDetailsUi;
		this._gitDetailsCore = options.gitDetailsCore;
		this._items = [];

		// Options.
		options.isResize = false;

		// Base.
		method.base.call(this, options);
	},

	/** @inheritdoc */
	_createControl: function method (options) {

		var gitDetails = this._gitDetails;

		this._control = $DIV('gitDetails')
			.appendTo(options.target);

/*		this._createItem({
			caption: 'Dealtap',
			gitDetails: this._gitDetailsUi,
			assetDetails: this._assetDetails
		});
*/
		this._createItem({
			caption: 'Dealtap',
			gitDetails: this._gitDetailsCore
		});
	},

	/**
	 * Creates item for given details.
	 * @param {Object} options
	 * @param {dt.entities.GitDetails} options.gitDetails
	 * @param {dt.entities.AssetDetails} options.assetDetails
	 * @private
	 */
	_createItem: function (options) {

		if (options.gitDetails) {

			// Item.
			this._items.push(new dt.controls.GitDetailsItem({
				target: this._control,
				caption: options.caption,
				gitDetails: options.gitDetails,
				assetDetails: options.assetDetails
			}));
		}
	},

	__classType: 'dt.controls.GitDetails'
});

/**
 * Item for details.
 */
dt.controls.GitDetailsItem = dt.controls.Control.extend({

	init: function method (options) {
		/**
		 * @param {Object} options
		 * @param {String} options.caption
		 * @param {dt.entities.GitDetails} options.gitDetails
		 * @param {dt.entities.AssetDetails} options.assetDetails
		 */

		options = options || {};

		// Properties.
		this._gitDetails = options.gitDetails || error;
		this._assetDetails = options.assetDetails || null;

		// Options.
		options.isResize = false;

		// Base.
		method.base.call(this, options);
	},

	/** @inheritodc */
	_createControl: function method (options) {

		var gitDetails = this._gitDetails,
			assetDetails = this._assetDetails,

			gitTimestamp,
			gitFriendly,

			minTimestamp,
			minFriendly,

			div;

		this._control = $DIV('gitDetailsItem')
			.appendTo(options.target);

		// Show builder number
		$DIV('gitDetailsItem-line')
			// .append('{0} v{1} [<b>{2}</b>]'.format(options.caption, gitDetails.revision, gitDetails.branch))
			.append('{0} {1} build number[<b>{2}</b>]'.format(options.caption,gitDetails.revision , gitDetails.branch))
			.appendTo(this._control);

		// Show commit id of git details
		// $DIV('gitDetailsItem-line')
		// 	.append('<a href="https://bitbucket.org/dealtap/{1}/commits/{0}" target="_blank">{0}</a>'.format(gitDetails.commit, gitDetails.repository))
		// 	.appendTo(this._control);

		if (gitDetails.timestamp) {

			gitTimestamp = dt.Utility.formatDate(gitDetails.timestamp, dt.enums.DateFormat.PRIMARY_TIME);
			gitFriendly = Date.friendly(gitDetails.timestamp);

			div = $DIV('gitDetailsItem-line')
				.append('{0}'.format(gitTimestamp))
				.appendTo(this._control);

			// If friendly date is not the same as timestamp.
			if (gitFriendly != gitTimestamp) {
				div.append(' - {0}'.format(gitFriendly));
			}
		}

		if (assetDetails) {

			div = $DIV('gitDetailsItem-line')
				.append('Minified: <b>{0}</b>'.format(assetDetails.isMin ? 'YES' : 'NO'))
				.appendTo(this._control);

			// If minified and have latest timestamp.
			if (assetDetails.isMin && assetDetails.timestampLatest) {

				minTimestamp = dt.Utility.formatDate(assetDetails.timestampLatest, dt.enums.DateFormat.PRIMARY_TIME);
				minFriendly = Date.friendly(assetDetails.timestampLatest);

				div.append(' at {0}'.format(minTimestamp));

				if (minFriendly != minTimestamp) {
					div.append(' - {0}'.format(minFriendly));
				}

				// If git has newer files than minified...
				if (gitDetails.timestamp.getTimestamp() > assetDetails.timestampLatest.getTimestamp()) {

					div = $DIV('gitDetailsItem-line')
						.append('<b>Minified files TOO OLD!</b>')
						.appendTo(this._control);
				}
			}
		}
	},

	__classType: 'dt.controls.GitDetailsItem'
});