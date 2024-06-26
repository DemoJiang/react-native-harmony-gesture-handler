import { RNOHContext, RNViewBase, ComponentBuilderContext, RNComponentFactory, Tag } from "@rnoh/react-native-openharmony"
import { RNC } from "@rnoh/react-native-openharmony/generated/ts"
import { RNGHRootTouchHandlerArkTS as RNGHRootTouchHandler } from "./RNGHRootTouchHandlerArkTS"
import { RNGestureHandlerModule } from "./RNGestureHandlerModule"


export type RNGestureHandlerRootViewDescriptor = RNC.RNGestureHandlerRootView.Descriptor

@Component
export struct RNGestureHandlerRootView {
  static readonly NAME = RNC.RNGestureHandlerRootView.NAME
  ctx!: RNOHContext
  tag: number = -1
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void
  @State descriptor: RNGestureHandlerRootViewDescriptor = {} as RNGestureHandlerRootViewDescriptor
  private unsubscribes: (() => void)[] = []
  private touchHandler: RNGHRootTouchHandler | undefined = undefined

  aboutToAppear() {
    const rnGestureHandlerModule = this.ctx.rnInstance.getTurboModule<RNGestureHandlerModule>(RNGestureHandlerModule.NAME)
    const rootTag = this.ctx.descriptorRegistry.getDescriptorLineage(this.tag)[0].tag
    this.touchHandler = new RNGHRootTouchHandler(rootTag, rnGestureHandlerModule.getViewRegistry(), rnGestureHandlerModule.getGestureHandlerRegistry(), rnGestureHandlerModule.getLogger())
    this.handleDescriptorChange(this.ctx.descriptorRegistry.getDescriptor<RNGestureHandlerRootViewDescriptor>(this.tag))
    this.unsubscribes.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag, (d) => {
      this.handleDescriptorChange(d as RNGestureHandlerRootViewDescriptor)
    }))
  }

  aboutToDisappear() {
    this.unsubscribes.forEach(unsubscribe => unsubscribe())
  }

  handleDescriptorChange(newDescriptor: RNGestureHandlerRootViewDescriptor) {
    this.descriptor = newDescriptor
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      ForEach(this.descriptor.childrenTags, (childrenTag: Tag) => {
        RNComponentFactory({ ctx: this.ctx, tag: childrenTag, buildCustomComponent: this.buildCustomComponent })
      })
      Stack() {
      }
      .width("100%")
      .height("100%")
      .onTouch((e) => {
        this.touchHandler?.handleTouch(e)
      })
      .hitTestBehavior(HitTestMode.Transparent)

    }
  }
}