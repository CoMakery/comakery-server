import React from 'react'
import { mount } from 'enzyme'
import BatchForm from 'components/BatchForm'

describe('BatchForm', () => {
  it('renders correctly without props', () => {
    const wrapper = mount(<BatchForm />)

    expect(wrapper).toMatchSnapshot()

    expect(wrapper.exists('Layout[title]')).toBe(true)
    expect(wrapper.exists('.batch-form')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="cancel"]')).toBe(true)
    expect(wrapper.exists('ButtonBorder[value="create"]')).toBe(true)
    expect(wrapper.exists('Button[value="create & close"]')).toBe(true)
    expect(wrapper.exists('.batch-form--message')).toBe(false)
    expect(wrapper.exists('.batch-form--form')).toBe(true)
    expect(wrapper.exists('#batch-form--form')).toBe(true)

    expect(wrapper.exists(
      'InputFieldWhiteDark[title="name"][required][name="batch[name]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescriptionMiddle[title="the goal of the batch"][name="batch[goal]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescription[title="description"][name="batch[description]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldUploadFile[title="diagram or screenshot"][name="batch[diagram]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'input[type="hidden"][name="authenticity_token"]'
    )).toBe(true)
  })

  it('renders correctly with a batch', () => {
    const batch = {
      'id'         : 10,
      'name'       : 'Batch name',
      'description': 'Batch description',
      'goal'       : 'Batch goal'
    }

    const wrapper = mount(<BatchForm
      batch={batch}
    />)

    expect(wrapper.find(
      'InputFieldWhiteDark[title="name"][required][name="batch[name]"]'
    ).props().value).toBe('Batch name')

    expect(wrapper.find(
      'InputFieldDescriptionMiddle[title="the goal of the batch"][name="batch[goal]"]'
    ).props().value).toBe('Batch goal')

    expect(wrapper.find(
      'InputFieldDescription[title="description"][name="batch[description]"]'
    ).props().value).toBe('Batch description')
  })

  it('renders correctly with csrfToken', () => {
    const wrapper = mount(<BatchForm csrfToken='test' />)

    expect(wrapper.find(
      'input[type="hidden"][name="authenticity_token"]'
    ).props().value).toBe('test')
  })

  it('uses formUrl', () => {
    const wrapper = mount(<BatchForm formUrl='/test' />)

    expect(wrapper.state('formUrl')).toBe('/test')
  })

  it('uses formAction', () => {
    const wrapper = mount(<BatchForm formAction='PUT' />)

    expect(wrapper.state('formAction')).toBe('PUT')
  })

  it('uses urlOnSuccess', () => {
    const wrapper = mount(<BatchForm urlOnSuccess='/test' />)

    expect(wrapper.props().urlOnSuccess).toBe('/test')
  })

  it('displays messages', () => {
    const wrapper = mount(<BatchForm />)

    wrapper.setState({
      flashMessages: [
        {
          'severity': 'notice',
          'text'    : 'notice text'
        },
        {
          'severity': 'warning',
          'text'    : 'warning text'
        },
        {
          'severity': 'error',
          'text'    : 'error text'
        }
      ]
    })

    wrapper.update()

    expect(wrapper.exists('Flash')).toBe(true)
  })

  it('displays errors', () => {
    const wrapper = mount(<BatchForm />)

    wrapper.setState({
      errors: {
        'batch[name]'       : 'name error',
        'batch[description]': 'description error'
      }
    })

    wrapper.update()

    expect(wrapper.exists(
      'InputFieldWhiteDark[errorText="name error"][title="name"][required][name="batch[name]"]'
    )).toBe(true)

    expect(wrapper.exists(
      'InputFieldDescription[errorText="description error"][title="description"][name="batch[description]"]'
    )).toBe(true)
  })
})
