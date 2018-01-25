<?php
/**
 * List of details about git.
 *
 * @copyright Copyright &copy; 2016 DealTap Group, Inc.
 * @package system/entities
 * @since 2.0
 */

namespace App\System\Entities;


use App\System\Utility;

class GitDetails {

	/**
	 * Repository these details are for.
	 * @var string
	 */
	public $repository;

	/**
	 * @var string The current branch.
	 */
	public $branch;

	/**
	 * Reference to commit number.
	 * @var string
	 */
	public $commit;

	/**
	 * @var integer Timestamp of current commit.
	 */
	public $timestamp;

	/**
	 * @var string Git tag for version
	 */
	public $tag_version;

	/**
	 * @var string Revision number - like a commit/build number.
	 */
	public $revision;

	/**
	 * GitDetails constructor.
	 * @param array $args Properties to initialize with.
	 */
	public function __construct(array $args) {

		$this->repository = Utility::arval($args, 'repository', $this->repository);
		$this->branch = Utility::arval($args, 'branch', $this->branch);
		$this->commit = Utility::arval($args, 'commit', $this->commit);
		$this->timestamp = Utility::arval($args, 'timestamp', $this->timestamp);
		$this->tag_version = Utility::arval($args, 'tag_version', $this->tag_version);
		$this->revision = Utility::arval($args, 'revision', $this->revision);
	}

	/**
	 * Gets git details from execution path.
	 * @returns GitDetails
	 */
	static public function from_exec() {

		exec('git rev-parse --abbrev-ref HEAD', $branch);
		exec('git describe --always', $tag_version);
		exec('git rev-list HEAD | wc -l', $revision);
//		exec('git log -1 | grep Date', $date);
		exec('git log -1 | grep commit', $commit);

        // Get the virtual path [media/sf_src/app_core/public]
        // Need to create a file called 'deploy_time' to record the release time
        // But the file have the same path name with 'app-core' and 'app-ui'
        exec('pwd', $path);

        // Check content of deploy_time file
        // The Command 'cat ../../deploy_time' return a array
        // The first element of the array is a string date value (millisecond)
        exec('cat ../../deploy_time', $date);


        if( $date ) { // Justify the time stamp file is exist or not

            // A variable to store release time
            // Need to convert millisecond to specific format
            $outputDate = date('Y-m-d h:i:s',$date[0]);

            // Get the time stamp value
            $outputDate = is_string($outputDate) ? $outputDate : Utility::arval($outputDate, 0);

        }

        // If the time stamp file is not exist
        // load time stamp from git
        else {

            // Execute linux git command to scrape time stamp
            // The time with specific format
            exec('git log -1 | grep Date', $outputDate);

            // To scrape the time string use 'str_replace' built-in method
            $outputDate = str_replace('Date:   ', '', is_string($outputDate) ? $outputDate : Utility::arval($outputDate, 0));
        }




		return new GitDetails([
			// TODO: reidenzon - Load from git? Eh...
			'repository' => 'app-core',
			'branch' => $branch,
			'commit' => str_replace('commit ', '', is_string($commit) ? $commit : Utility::arval($commit, 0)),
			'tag_version' => $tag_version[0],
			'timestamp' => strtotime( $outputDate ),
//            'timestamp' => strtotime( is_string( $outputDate ) ? $outputDate : Utility::arval($outputDate, 0) ),
//			'revision' => '2.0.'.$revision[0]
			'revision' => '3.0'
		]);
	}
}