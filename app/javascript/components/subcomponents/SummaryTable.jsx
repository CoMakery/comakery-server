import React from 'react';
import PropTypes from 'prop-types';
import ReactPaginate from 'react-paginate';

export default class SummaryTable extends React.Component {
	constructor(props) {
		super(props);
	}

	render() {
		return (
			<React.Fragment>
				<div className="columns medium-12 no-h-pad">
					<h4 style={{ border: 'none' }}>Awards</h4>
					<div className="table-scroll table-box full-width" style={{ marginRight: 0 }}>
						<table className="award-rows full-width">
							<tbody>
								<tr className="header-row">
									<th className="small-4">Project</th>
									<th className="small-1">Token</th>
									<th className="small-2">Total Awarded</th>
									<th className="small-5">Token Contract Address</th>
								</tr>
								{this.props.projects.map(project =>
									<tr className="award-row" key={project.id}>
										<td className="small-4">
											<a href={project.awards_path}>
												{project.title}
											</a>
										</td>
										<td className="small-1">
											{project.token_symbol || 'pending'}
										</td>
										<td className="small-2">
											{project.total_awarded}
										</td>
										<td className="small-5">
											{project.ethereum_contract_address
												? <a href={project.ethereum_contract_explorer_url}>
														{project.ethereum_contract_address}
													</a>
												: 'pending'}
										</td>
									</tr>
								)}
							</tbody>
						</table>
					</div>
				</div>
				<div className="columns medium-12 no-h-pad text-right">
					<ReactPaginate
						containerClassName="react-pagination"
						activeClassName="active"
						pageCount={this.props.pageCount}
						marginPagesDisplayed={2}
						pageRangeDisplayed={2}
						initialPage={this.props.currentPage}
						onPageChange={data => {
							this.props.handlePageChange(data.selected);
						}}
					/>
				</div>
			</React.Fragment>
		);
	}
}

SummaryTable.propTypes = {
	projects: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
	pageCount: PropTypes.number.isRequired,
	currentPage: PropTypes.number.isRequired,
	handlePageChange: PropTypes.func.isRequired,
};
