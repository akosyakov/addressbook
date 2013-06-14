package com.example.addressbook

import com.vaadin.annotations.Title
import com.vaadin.data.Container
import com.vaadin.data.Item
import com.vaadin.data.fieldgroup.FieldGroup
import com.vaadin.data.util.IndexedContainer
import com.vaadin.server.VaadinRequest
import com.vaadin.ui.AbstractTextField.TextChangeEventMode
import com.vaadin.ui.Button
import com.vaadin.ui.Component
import com.vaadin.ui.ComponentContainer
import com.vaadin.ui.FormLayout
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.HorizontalSplitPanel
import com.vaadin.ui.Table
import com.vaadin.ui.TextField
import com.vaadin.ui.UI
import com.vaadin.ui.VerticalLayout
import java.util.Random

import static com.example.addressbook.Constants.*

@Title("Addressbook")
class AddressbookUI extends UI {

	private static final String[] FIELD_NAMES = #[FNAME, LNAME, COMPANY, "Mobile Phone", "Work Phone", "Home Phone", "Work Email", "Home Email", "Street", "City", "Zip", "State", "Country"]

	private static final String[] FNAMES = #["Peter", "Alice", "Joshua", "Mike", "Olivia", "Nina", "Alex", "Rita", "Dan", "Umberto", "Henrik", "Rene", "Lisa", "Marge"]

	private static final String[] LNAMES = #["Smith", "Gordon", "Simpson", "Brown", "Clavel", "Simons", "Verne", "Scott", "Allison", "Gates", "Rowling", "Barks", "Ross", "Schneider", "Tate"]

	private Table contactList

	private FormLayout editorLayout

	private FieldGroup editorFields

	override protected init(VaadinRequest request) {
		content = new HorizontalSplitPanel => [
			it += new VerticalLayout => [
				contactList = it += createContactList()
				it += createBottomLeftLayout()
				setSizeFull
				setExpandRatio(contactList, 1)
			]
			editorLayout = it += createEditorLayout()
		]
	}

	def protected createContactList() {
		new Table => [
			setSizeFull
			containerDataSource = new IndexedContainer
			FIELD_NAMES.forEach[fieldName|addContainerProperty(fieldName, typeof(String), "")]
			val random = new Random()
			(0 .. 1000).forEach [ i |
				val id = addItem()
				setValue(id, FNAME, FNAMES.get(random.nextInt(FNAMES.length)))
				setValue(id, LNAME, LNAMES.get(random.nextInt(LNAMES.length)))
			]
			visibleColumns = #[FNAME, LNAME, COMPANY]
			selectable = true
			immediate = true
			addValueChangeListener[ e |
				val contactId = getValue()
				if (contactId != null) {
					editorFields.itemDataSource = getItem(contactId)
				}
				editorLayout.visible = contactId != null
			]
		]
	}

	def setValue(Table it, Object itemId, Object propertyId, Object value) {
		getContainerProperty(itemId, propertyId).value = value
	}

	def contactContainer(Table it) {
		containerDataSource as IndexedContainer
	}

	def protected createBottomLeftLayout() {
		new HorizontalLayout => [
			setExpandRatio(
				it += new TextField => [
					width = "100%"
					inputPrompt = "Search contacts"
					textChangeEventMode = TextChangeEventMode.LAZY
					addTextChangeListener [
						contactList.contactContainer.removeAllContainerFilters
						contactList.contactContainer.addContainerFilter(new ContactFilter(text))
					]
				], 1)
			it += new Button("New",
				[
					contactList.contactContainer.removeAllContainerFilters
					val contactId = contactList.contactContainer.addItemAt(0)
					contactList.setValue(contactId, FNAME, "New")
					contactList.setValue(contactId, LNAME, "Contact")
					contactList.select(contactId)
				])
			width = "100%"
		]
	}

	def protected createEditorLayout() {
		new FormLayout => [
			margin = true
			visible = false
			it += new Button("Remove this contact",
				[
					contactList.removeItem(contactList.value)
				])
			editorFields = new FieldGroup => [
				buffered = false
			]
			FIELD_NAMES.forEach [ fieldName |
				editorFields.bind(
					it += new TextField(fieldName) => [
						width = "100%"
					], fieldName)
			]
		]
	}

	def <T extends Component> operator_add(ComponentContainer it, T component) {
		addComponent(component)
		component
	}

}

class ContactFilter implements Container.Filter {

	private String needle;

	new(String needle) {
		this.needle = needle.toLowerCase
	}

	override appliesToProperty(Object propertyId) {
		true
	}

	override passesFilter(Object itemId, Item item) {
		'''«item.getItemProperty(FNAME).value»«item.getItemProperty(LNAME).value»«item.getItemProperty(COMPANY).value»'''.
			toString.toLowerCase.contains(needle)
	}

}

class Constants {

	public static final String FNAME = "First Name"

	public static final String LNAME = "Last Name"

	public static final String COMPANY = "Company"

}
