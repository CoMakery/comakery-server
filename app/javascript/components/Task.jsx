import React from 'react'
import PropTypes from 'prop-types'
import styled, { css } from 'styled-components'
import Icon from './styleguide/Icon'
import Userpics from './Userpics'
import CurrencyAmount from './CurrencyAmount'
import ContentBlock from './ContentBlock'
import Pluralize from 'react-pluralize'

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  margin-bottom: 10px;
  border-left: 2px solid;
  border-color: #5037f7;

  ${props => props.status === 'ready' && css`
    border-color: #4a4a4a;
  `}

  ${props => props.status === 'invite ready' && css`
    border-color: #4a4a4a;
  `}

  ${props => props.status === 'started' && css`
    border-color: #008e9b;
  `}

  ${props => props.status === 'submitted' && css`
    border-color: #007ae7;
  `}

  ${props => props.status === 'accepted' && css`
    border-color: #5037f7;
  `}

  ${props => props.status === 'paid' && css`
    border-color: #fb40e5;
  `}

  ${props => props.status === 'rejected' && css`
    border-color: #ff4d4d;
  `}

  ${props => props.status === 'cancelled' && css`
    border-color: #ff4d4d;
  `}
`

const Info = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;

  @media (max-width: 1024px) {
    flex-direction: column;
    align-items: flex-start;
  }
`

const Name = styled.div`
  font-family: Montserrat;
  font-size: 14px;
  font-weight: 600;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #3a3a3a;
  padding-bottom: 8px;
`

const StatusWrapper = styled.div`
  display: flex;
  padding: 7px 15px;

  & > div {
    margin-bottom: 1em;
  }

  @media (max-width: 1024px) {
    flex-direction: column;
  }
`

const Status = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: uppercase;
  margin-right: 2em;

  ${props => props.status === 'ready' && css`
    color: #4a4a4a;
  `}

  ${props => props.status === 'invite ready' && css`
    color: #4a4a4a;
  `}

  ${props => props.status === 'started' && css`
    color: #008e9b;
  `}

  ${props => props.status === 'submitted' && css`
    color: #007ae7;
  `}

  ${props => props.status === 'accepted' && css`
    color: #5037f7;
  `}

  ${props => props.status === 'paid' && css`
    color: #fb40e5;
  `}

  ${props => props.status === 'rejected' && css`
    color: #ff4d4d;
  `}

  ${props => props.status === 'cancelled' && css`
    color: #ff4d4d;
  `}
`
const CloneInfo = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  text-transform: uppercase;
  margin-right: 2em;

  b {
    font-weight: 600;
  }

  span {
    margin-left: 0.5em;
  }
`

const Contributor = styled.div`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: 500;
  color: #4a4a4a;
  text-transform: uppercase;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  flex-wrap: nowrap;
  display: flex;
  margin-right: 2em;

  b {
    font-weight: 900;
  }
`

const Title = styled.div`
  padding: 15px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  @media (max-width: 1024px) {
    padding-bottom: 0;
  }
`

const Details = styled.div`
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: space-between;
  padding-right: 15px;
  padding-top: 7px;

  @media (max-width: 1024px) {
    padding: 7px 15px;
    flex-direction: column;
    align-items: flex-start;
  }
`

const Amount = styled(CurrencyAmount)`
`

const Buttons = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 8px;

  @media (max-width: 1024px) {
    justify-content: flex-start;
  }
`

const PaymentButton = styled.a`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #0089f4;
  text-decoration: none;
  text-transform: uppercase;

  &:hover,
  &:focus {
    text-decoration: underline;
  }

  @media (max-width: 1024px) {
    margin-left: 0px;
    margin-right: 16px;
  }
`

const StyledIcon = styled(Icon)`
  height: 15px;
  width: 15px;
  margin-left: 16px;

  @media (max-width: 1024px) {
    margin-left: 0px;
    margin-right: 16px;
  }
`

const IconPlaceholder = styled(Icon)`
  height: 15px;
  width: 15px;
  margin-left: 16px;
  opacity: 0.3;
  cursor: not-allowed;

  @media (max-width: 1024px) {
    margin-left: 0px;
    margin-right: 16px;
  }
`

const TaskDetails = styled.a`
  font-family: Montserrat;
  font-size: 10px;
  font-weight: bold;
  font-style: normal;
  font-stretch: normal;
  line-height: normal;
  letter-spacing: normal;
  color: #201662;
  margin-left: auto;
  text-transform: uppercase;
  text-decoration: none;
  display: flex;
  flex-direction: row;
  align-items: center;
  cursor: pointer;
  margin: .5em 1.5em .5em auto;

  &:hover {
    text-decoration: underline;
  }

  img {
    margin-left: 7px;
    ${props => props.rotateIcon && css`
      transform: rotate(180deg);
    `}
  }

  @media (max-width: 1024px) {
    margin-left: initial;
    padding: 7px 15px;
  }
`

const DetailsBox = styled.div`
  padding: 30px 40px;
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  background-color: #ffffff;
  margin-top: -9px;
  margin-bottom: 20px;

  img {
    max-width: 80px;
    max-height: 80px;
    border: 1px solid transparent;

    &:hover {
      border: 1px solid #0089f4;
    }
  }
`

const BottomWrapper = styled.div`
  display: flex;

  @media (max-width: 1024px) {
    flex-direction: column;
  }
`

class Task extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      showDetailsBox: false
    }
  }

  render() {
    let task = this.props.task
    return (
      <React.Fragment>
        <Wrapper status={task.status}>
          <Info>
            <Title>
              <Name>
                {task.name || task.batchName}
              </Name>
            </Title>

            <Details>
              <Amount
                amount={task.totalAmount}
                currency={task.currency}
                logoUrl={task.currencyLogo}
              />

              {this.props.editable &&
                <Buttons>
                  {(task.status === 'ready' || task.status === 'invite ready') &&
                    <PaymentButton href={task.awardPath}>
                        issue award
                    </PaymentButton>
                  }

                  {task.status === 'accepted' &&
                    <PaymentButton href={task.payPath}>
                        pay contributor
                    </PaymentButton>
                  }

                  {(task.status === 'ready' || task.status === 'invite ready') &&
                    <a href={task.assignPath}>
                      <StyledIcon name='INVITE_USER.svg' />
                    </a>
                  }

                  {!(task.status === 'ready' || task.status === 'invite ready') &&
                    <IconPlaceholder name='INVITE_USER.svg' />
                  }

                  <a href={task.clonePath}>
                    <StyledIcon name='DUPLICATE.svg' />
                  </a>

                  {task.editPath &&
                    <a href={task.editPath}>
                      <StyledIcon name='iconEdit.svg' />
                    </a>
                  }

                  {!task.editPath &&
                    <IconPlaceholder name='iconEdit.svg' />
                  }

                  {task.destroyPath &&
                    <a rel='nofollow' data-method='delete' data-turbo='false' href={task.destroyPath}>
                      <StyledIcon name='iconTrash.svg' />
                    </a>
                  }

                  {!task.destroyPath &&
                    <IconPlaceholder name='iconTrash.svg' />
                  }
                </Buttons>
              }
            </Details>
          </Info>

          <BottomWrapper>
            <StatusWrapper>
              <Status status={task.status}>
                {task.status}
              </Status>

              {task.cloneable &&
                <CloneInfo>
                  <b>template</b>
                  <span>{task.numberOfClones + 1}/{task.numberOfAssignments}</span>
                </CloneInfo>
              }

              {task.cloned &&
                <CloneInfo>
                  <b>clone</b>
                </CloneInfo>
              }

              {task.contributor.name &&
                <Contributor>
                  <Userpics pics={[task.contributor.image]} limit={1} />
                  {task.contributor.name}
                </Contributor>
              }
            </StatusWrapper>

            <TaskDetails rotateIcon={this.state.showDetailsBox} onClick={(_) => this.setState({showDetailsBox: (!this.state.showDetailsBox)})}>
              Details <Icon name='DROP_DOWN.svg' />
            </TaskDetails>
          </BottomWrapper>
        </Wrapper>

        {this.state.showDetailsBox &&
          <DetailsBox>
            <ContentBlock title='what is the expected benefit'>
              {task.why}
            </ContentBlock>

            <ContentBlock title='description'>
              <div dangerouslySetInnerHTML={{__html: task.descriptionHtml}} />
            </ContentBlock>

            {task.imageUrl &&
              <ContentBlock>
                <a target='_blank' href={task.imageUrl}>
                  <img src={task.imageUrl} />
                </a>
              </ContentBlock>
            }

            <ContentBlock title='acceptance criteria'>
              <div dangerouslySetInnerHTML={{__html: task.requirementsHtml}} />
            </ContentBlock>

            <ContentBlock title='days till task expires (after starting)'>
              <Pluralize singular='day' count={task.expiresInDays} />
            </ContentBlock>

            {task.proofLink &&
              <ContentBlock title='URL where to submit completed work'>
                <a href={task.proofLink} target='_blank'>{task.proofLink}</a>
              </ContentBlock>
            }
          </DetailsBox>
        }
      </React.Fragment>
    )
  }
}

Task.propTypes = {
  task    : PropTypes.object,
  editable: PropTypes.bool
}
Task.defaultProps = {
  task: {
    status     : null,
    contributor: {
      name : null,
      image: null
    }
  },
  editable: true
}
export default Task
