import { RNOHContext, RNViewBase, ComponentBuilderContext, RNComponentFactory, Tag } from "@rnoh/react-native-openharmony"
import { RNC } from "@rnoh/react-native-openharmony/generated"

export type RNGestureHandlerButtonDescriptor = RNC.RNGestureHandlerButton.Descriptor

@Component
export struct RNGestureHandlerButton {
  static readonly NAME = RNC.RNGestureHandlerButton.NAME
  public ctx!: RNOHContext
  public tag: number = -1
  @BuilderParam public buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void

  @State private descriptor: RNGestureHandlerButtonDescriptor = {} as RNGestureHandlerButtonDescriptor
  private unsubscribes: (() => void)[] = []

  aboutToAppear() {
    this.handleDescriptorChange(this.ctx.descriptorRegistry.getDescriptor<RNGestureHandlerButtonDescriptor>(this.tag))
    this.unsubscribes.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag, (d) => {
      this.handleDescriptorChange(d as RNGestureHandlerButtonDescriptor)
    }))
  }

  aboutToDisappear() {
    this.unsubscribes.forEach(unsubscribe => unsubscribe())
  }

  handleDescriptorChange(newDescriptor: RNGestureHandlerButtonDescriptor) {
    this.descriptor = newDescriptor
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      ForEach(this.descriptor.childrenTags, (childrenTag: Tag) => {
        RNComponentFactory({ ctx: this.ctx, tag: childrenTag, buildCustomComponent: this.buildCustomComponent })
      })
    }
  }
}